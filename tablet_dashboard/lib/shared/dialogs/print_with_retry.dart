import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/printer/bluetooth_printer.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Cetak [bytes], kalau gagal kasir bisa coba lagi atau lewati.
// true = berhasil dicetak
Future<bool> printWithRetry(BuildContext context, Uint8List bytes) async {
  while (true) {
    if (!context.mounted) return false;
    final error = await _printOnce(context, bytes);
    if (error == null) return true;
    if (!context.mounted) return false;

    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Struk gagal dicetak', style: AppTextStyle.title),
        content: Text(
          '$error\n\nCek printer di menu Konfigurasi.',
          style: AppTextStyle.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Lewati'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
    if (retry != true) return false;
  }
}

// Kirim ke printer sambil tampil "Mencetak…", balikin pesan error atau null
Future<String?> _printOnce(BuildContext context, Uint8List bytes) async {
  final printer = context.read<PrinterController>();
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _PrintingDialog(),
  );
  try {
    await printer.printBytes(bytes);
    return null;
  } on PrinterException catch (e) {
    return e.message;
  } finally {
    navigator.pop();
  }
}

class _PrintingDialog extends StatelessWidget {
  const _PrintingDialog();

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(width: 16),
            Text('Mencetak struk…', style: AppTextStyle.bodyBold),
          ],
        ),
      ),
    );
  }
}
