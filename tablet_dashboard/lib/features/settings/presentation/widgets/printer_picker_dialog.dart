import 'package:flutter/material.dart';

import '../../../../core/printer/bluetooth_printer.dart';
import '../../../../core/printer/printer_controller.dart';
import '../../../../core/theme/app_color.dart';

/// Lists printers already paired in Android Bluetooth settings; pops the chosen one.
class PrinterPickerDialog extends StatefulWidget {
  const PrinterPickerDialog({super.key, required this.controller});

  final PrinterController controller;

  @override
  State<PrinterPickerDialog> createState() => _PrinterPickerDialogState();
}

class _PrinterPickerDialogState extends State<PrinterPickerDialog> {
  bool _loading = true;
  String? _error;

  PrinterController get _printer => widget.controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() => _guard(_printer.loadDevices);

  Future<void> _disconnect() => _guard(_printer.disconnect);

  Future<void> _guard(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } on PrinterException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final connected = _printer.status == PrinterStatus.connected;

    return AlertDialog(
      title: const Text('Pilih Printer'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Printer yang sudah di-pair di Pengaturan Bluetooth tablet.',
              style: TextStyle(color: AppColor.inkSoft),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _Message(icon: Icons.bluetooth_disabled, text: _error!)
            else if (_printer.devices.isEmpty)
              const _Message(icon: Icons.print_disabled, text: 'Belum ada perangkat yang di-pair.')
            else
              for (final device in _printer.devices)
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.print_outlined),
                  title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(device.address),
                  trailing: device.address == _printer.selected?.address
                      ? const Icon(Icons.check_circle, color: AppColor.gold)
                      : null,
                  onTap: () => Navigator.pop(context, device),
                ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColor.goldSoft, borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Printer belum muncul? Buka Pengaturan > Bluetooth, pair ke '
                '"${PrinterController.defaultPrinterName}" dengan PIN 0000, lalu tekan Muat ulang.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (connected) TextButton(onPressed: _loading ? null : _disconnect, child: const Text('Putuskan')),
        TextButton(onPressed: _loading ? null : _load, child: const Text('Muat ulang')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColor.inkFaint),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
