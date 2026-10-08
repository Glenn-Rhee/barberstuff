import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/printer/bluetooth_printer.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Hasil satu kali cetak: error null = berhasil, skipped = kasir menekan Lewati
typedef _PrintResult = ({bool skipped, String? error});

// Cetak dengan opsi coba lagi / lewati. true = berhasil
Future<bool> printWithRetry(BuildContext context, Uint8List bytes) async {
  final printer = context.read<PrinterController>();
  while (true) {
    if (!context.mounted) return false;
    final result = await showDialog<_PrintResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PrintingDialog(printer: printer, bytes: bytes),
    );
    if (result == null || result.skipped) return false;
    if (result.error == null) return true;
    if (!context.mounted) return false;

    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Struk gagal dicetak', style: AppTextStyle.title),
        content: Text(
          '${result.error}\n\nCek printer di menu Konfigurasi.',
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

// Kirim ke printer sambil tampil "Mencetak…", tutup sendiri dengan hasilnya
class _PrintingDialog extends StatefulWidget {
  const _PrintingDialog({required this.printer, required this.bytes});

  final PrinterController printer;
  final Uint8List bytes;

  @override
  State<_PrintingDialog> createState() => _PrintingDialogState();
}

class _PrintingDialogState extends State<_PrintingDialog> {
  // Tombol Lewati baru muncul kalau printer lama merespons
  static const _skipDelay = Duration(seconds: 3);

  late final Timer _skipTimer;
  bool _showSkip = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _skipTimer = Timer(_skipDelay, () => setState(() => _showSkip = true));
    _print();
  }

  @override
  void dispose() {
    _skipTimer.cancel();
    super.dispose();
  }

  Future<void> _print() async {
    String? error;
    try {
      await widget.printer.printBytes(widget.bytes);
    } on PrinterException catch (e) {
      error = e.message;
    }
    _close((skipped: false, error: error));
  }

  // Hentikan konek/cetak di native supaya printer tidak tertahan "sibuk"
  void _skip() {
    widget.printer.cancel().ignore();
    _close((skipped: true, error: null));
  }

  // Cetak bisa selesai pas animasi tutup habis Lewati, jadi pop cukup sekali
  void _close(_PrintResult result) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
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
            if (_showSkip)
              TextButton(onPressed: _skip, child: const Text('Lewati')),
          ],
        ),
      ),
    );
  }
}
