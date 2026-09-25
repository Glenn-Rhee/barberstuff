package com.example.tablet_dashboard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var printer: BluetoothPrinterChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = BluetoothPrinterChannel(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BluetoothPrinterChannel.CHANNEL)
            .setMethodCallHandler(channel)
        printer = channel
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        if (printer?.onRequestPermissionsResult(requestCode, grantResults) == true) return
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onDestroy() {
        printer?.dispose()
        printer = null
        super.onDestroy()
    }
}
