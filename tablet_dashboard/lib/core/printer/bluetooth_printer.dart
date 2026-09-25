import 'package:flutter/services.dart';

class PrinterDevice {
  const PrinterDevice({required this.name, required this.address});

  final String name;
  final String address;
}

class PrinterException implements Exception {
  const PrinterException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Dart side of `BluetoothPrinterChannel.kt` (Android only, Bluetooth Classic SPP).
class BluetoothPrinter {
  const BluetoothPrinter();

  static const _channel = MethodChannel('barberstuff/bluetooth_printer');

  /// Devices already paired in the tablet's Bluetooth settings.
  Future<List<PrinterDevice>> bondedDevices() async {
    final raw = await _invoke<List<Object?>>('bondedDevices') ?? const [];
    return [
      for (final device in raw.cast<Map<Object?, Object?>>())
        PrinterDevice(name: device['name']! as String, address: device['address']! as String),
    ];
  }

  Future<void> connect(String address) => _invoke<void>('connect', {'address': address});

  Future<void> disconnect() => _invoke<void>('disconnect');

  Future<bool> isConnected() async => await _invoke<bool>('isConnected') ?? false;

  Future<void> write(Uint8List bytes) => _invoke<void>('write', {'bytes': bytes});

  Future<T?> _invoke<T>(String method, [Map<String, Object?>? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw PrinterException(e.message ?? e.code);
    } on MissingPluginException {
      throw const PrinterException('Printer Bluetooth hanya tersedia di Android');
    }
  }
}
