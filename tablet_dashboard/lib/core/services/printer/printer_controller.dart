import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/services/printer/bluetooth_printer.dart';

enum PrinterStatus { disconnected, connecting, connected, printing }

class PrinterController extends ChangeNotifier {
  PrinterController({this._printer = const BluetoothPrinter()});

  // Nama Bluetooth Panda PRJ-R58D, otomatis dipilih kalau sudah di-pair
  static const defaultPrinterName = 'RPP210A';

  final BluetoothPrinter _printer;

  List<PrinterDevice> devices = const [];
  PrinterDevice? selected;
  PrinterStatus status = PrinterStatus.disconnected;

  bool get busy =>
      status == PrinterStatus.connecting || status == PrinterStatus.printing;

  Future<void> loadDevices() async {
    devices = await _printer.bondedDevices();
    selected =
        devices.where((d) => d.address == selected?.address).firstOrNull ??
        devices.where((d) => d.name == defaultPrinterName).firstOrNull ??
        devices.firstOrNull;
    notifyListeners();
  }

  Future<void> connect(PrinterDevice device) async {
    selected = device;
    _setStatus(PrinterStatus.connecting);
    try {
      await _printer.connect(device.address);
      _setStatus(PrinterStatus.connected);
    } catch (_) {
      _setStatus(PrinterStatus.disconnected);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await _printer.disconnect();
    _setStatus(PrinterStatus.disconnected);
  }

  // Sambungkan dulu kalau belum, lalu kirim [bytes] ke printer
  Future<void> printBytes(Uint8List bytes) async {
    final device = selected;
    if (device == null) {
      throw const PrinterException(
        'Belum ada printer. Pair RPP210A dulu di pengaturan Bluetooth.',
      );
    }
    if (busy) {
      throw const PrinterException('Printer masih sibuk, tunggu sebentar');
    }
    if (!await _printer.isConnected()) await connect(device);

    _setStatus(PrinterStatus.printing);
    try {
      await _printer.write(bytes);
      _setStatus(PrinterStatus.connected);
    } catch (_) {
      _setStatus(
        await _printer.isConnected()
            ? PrinterStatus.connected
            : PrinterStatus.disconnected,
      );
      rethrow;
    }
  }

  // Batalkan konek/cetak yang sedang jalan (tombol Lewati). Status ikut
  // dibereskan oleh printBytes begitu panggilan native-nya gagal.
  Future<void> cancel() => _printer.cancel();

  void _setStatus(PrinterStatus value) {
    status = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _printer.disconnect().ignore();
    super.dispose();
  }
}
