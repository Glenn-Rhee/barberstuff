import 'package:flutter/foundation.dart';

import 'bluetooth_printer.dart';

enum PrinterStatus { disconnected, connecting, connected, printing }

class PrinterController extends ChangeNotifier {
  PrinterController({this._printer = const BluetoothPrinter()});

  /// Bluetooth name of the Panda PRJ-R58D, picked automatically when paired.
  static const defaultPrinterName = 'RPP210A';

  final BluetoothPrinter _printer;

  List<PrinterDevice> devices = const [];
  PrinterDevice? selected;
  PrinterStatus status = PrinterStatus.disconnected;

  bool get busy => status == PrinterStatus.connecting || status == PrinterStatus.printing;

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

  /// Connects to the selected printer if needed, then sends [bytes].
  Future<void> printBytes(Uint8List bytes) async {
    final device = selected;
    if (device == null) {
      throw const PrinterException('Belum ada printer. Pair RPP210A dulu di pengaturan Bluetooth.');
    }
    if (busy) throw const PrinterException('Printer masih sibuk, tunggu sebentar');
    if (!await _printer.isConnected()) await connect(device);

    _setStatus(PrinterStatus.printing);
    try {
      await _printer.write(bytes);
      _setStatus(PrinterStatus.connected);
    } catch (_) {
      _setStatus(await _printer.isConnected() ? PrinterStatus.connected : PrinterStatus.disconnected);
      rethrow;
    }
  }

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
