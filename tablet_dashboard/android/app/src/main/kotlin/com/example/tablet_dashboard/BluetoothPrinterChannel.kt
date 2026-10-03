package com.example.tablet_dashboard

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors

/**
 * Sends raw ESC/POS bytes to a paired Bluetooth Classic (SPP) receipt printer,
 * e.g. Panda PRJ-R58D which advertises itself as "RPP210A".
 */
@SuppressLint("MissingPermission")
class BluetoothPrinterChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "barberstuff/bluetooth_printer"
        private const val PERMISSION_REQUEST_CODE = 4521
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

        // Cheap printers have a small input buffer, so large payloads are sent in chunks.
        private const val CHUNK_SIZE = 256
        private const val CHUNK_DELAY_MS = 10L
    }

    private val adapter: BluetoothAdapter? =
        (activity.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?)?.adapter
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var socket: BluetoothSocket? = null

    // Socket yang sedang connect(), supaya bisa ditutup saat kasir menekan Lewati
    @Volatile
    private var connecting: BluetoothSocket? = null

    @Volatile
    private var cancelled = false

    private var pendingResult: MethodChannel.Result? = null
    private var pendingAction: (() -> Unit)? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "bondedDevices" -> withPermission(result) { bondedDevices(result) }
            "connect" -> withPermission(result) { connect(call.argument<String>("address")!!, result) }
            "write" -> write(call.argument<ByteArray>("bytes")!!, result)
            "isConnected" -> result.success(socket?.isConnected == true)
            // Sengaja tidak lewat executor: connect()/write() yang lagi blocking ada di sana
            "cancel" -> {
                cancel()
                result.success(null)
            }
            "disconnect" -> executor.execute {
                closeSocket()
                mainHandler.post { result.success(null) }
            }
            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE) return false
        val result = pendingResult
        val action = pendingAction
        pendingResult = null
        pendingAction = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            action?.invoke()
        } else {
            result?.error("PERMISSION_DENIED", "Izin Bluetooth ditolak. Aktifkan di pengaturan aplikasi.", null)
        }
        return true
    }

    fun dispose() {
        executor.execute { closeSocket() }
        executor.shutdown()
    }

    private fun hasPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            activity.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED

    private fun withPermission(result: MethodChannel.Result, action: () -> Unit) {
        if (hasPermission()) return action()
        if (pendingResult != null) return result.error("BUSY", "Masih menunggu izin Bluetooth", null)
        pendingResult = result
        pendingAction = action
        activity.requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), PERMISSION_REQUEST_CODE)
    }

    private fun readyAdapter(result: MethodChannel.Result): BluetoothAdapter? {
        val adapter = adapter
        if (adapter == null) {
            result.error("NO_BLUETOOTH", "Perangkat ini tidak punya Bluetooth", null)
            return null
        }
        if (!adapter.isEnabled) {
            result.error("BLUETOOTH_OFF", "Bluetooth mati. Nyalakan Bluetooth dulu.", null)
            return null
        }
        return adapter
    }

    private fun bondedDevices(result: MethodChannel.Result) {
        val adapter = readyAdapter(result) ?: return
        result.success(
            adapter.bondedDevices.map { mapOf("name" to (it.name ?: it.address), "address" to it.address) },
        )
    }

    private fun connect(address: String, result: MethodChannel.Result) {
        val adapter = readyAdapter(result) ?: return
        cancelled = false
        executor.execute {
            closeSocket()
            try {
                socket = openSocket(adapter, adapter.getRemoteDevice(address))
                mainHandler.post { result.success(true) }
            } catch (e: Exception) {
                mainHandler.post {
                    result.error("CONNECT_FAILED", "Gagal konek ke printer. Pastikan printer nyala & sudah di-pair. (${e.message})", null)
                }
            }
        }
    }

    // Tries the standard SPP socket first, then the fallbacks some cheap printers need.
    private fun openSocket(adapter: BluetoothAdapter, device: BluetoothDevice): BluetoothSocket {
        runCatching { adapter.cancelDiscovery() }
        val factories = listOf<() -> BluetoothSocket>(
            { device.createRfcommSocketToServiceRecord(SPP_UUID) },
            { device.createInsecureRfcommSocketToServiceRecord(SPP_UUID) },
            {
                device.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType)
                    .invoke(device, 1) as BluetoothSocket
            },
        )
        var lastError: Exception? = null
        for (create in factories) {
            if (cancelled) break
            val candidate = try {
                create()
            } catch (e: Exception) {
                lastError = e
                continue
            }
            try {
                connecting = candidate
                if (cancelled) throw IOException("dibatalkan")
                candidate.connect()
                if (cancelled) throw IOException("dibatalkan")
                return candidate
            } catch (e: IOException) {
                lastError = e
                runCatching { candidate.close() }
            } finally {
                connecting = null
            }
        }
        throw IOException(lastError?.message ?: "socket tidak bisa dibuka", lastError)
    }

    private fun write(bytes: ByteArray, result: MethodChannel.Result) {
        val current = socket
        if (current == null || !current.isConnected) {
            return result.error("NOT_CONNECTED", "Printer belum terhubung", null)
        }
        executor.execute {
            try {
                val out = current.outputStream
                var offset = 0
                while (offset < bytes.size) {
                    val size = minOf(CHUNK_SIZE, bytes.size - offset)
                    out.write(bytes, offset, size)
                    out.flush()
                    offset += size
                    Thread.sleep(CHUNK_DELAY_MS)
                }
                mainHandler.post { result.success(true) }
            } catch (e: Exception) {
                closeSocket()
                mainHandler.post {
                    result.error("WRITE_FAILED", "Koneksi printer terputus, coba cetak lagi. (${e.message})", null)
                }
            }
        }
    }

    // Menutup socket dari thread lain membuat connect()/write() yang blocking langsung gagal
    private fun cancel() {
        cancelled = true
        runCatching { connecting?.close() }
        runCatching { socket?.close() }
    }

    private fun closeSocket() {
        runCatching { socket?.close() }
        socket = null
    }
}
