import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_color.dart';
import '../core/theme/app_text_style.dart';
import '../data/api/barberstuff_api.dart';
import '../features/reservation/presentation/provider/bookings_controller.dart';
import '../shared/widgets/common.dart';
import 'navigation_controller.dart';

/// Checks a booking in with its QR code (`PATCH /staff/booking/checkin/{qr}`).
///
/// USB/Bluetooth barcode scanners type like a keyboard, so a focused text field
/// is all the hardware needs.
Future<void> scanBarcode(BuildContext context) async {
  final code = await showDialog<String>(context: context, builder: (_) => const _ScanDialog());
  if (code == null || code.trim().isEmpty || !context.mounted) return;

  final api = context.read<BarberstuffApi>();
  try {
    await api.checkIn(code.trim());
  } on ApiException catch (e) {
    if (context.mounted) AppToast.show(context, e.message, error: true);
    return;
  }
  if (!context.mounted) return;

  context.read<NavigationController>().openKasir(KasirTab.reservasi);
  await context.read<BookingsController>().refresh();
  if (context.mounted) AppToast.show(context, 'Check-in berhasil');
}

class _ScanDialog extends StatefulWidget {
  const _ScanDialog();

  @override
  State<_ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<_ScanDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit([String? value]) => Navigator.pop(context, value ?? _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan QR Booking', style: AppTextStyle.sectionTitle),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.goldSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.goldBorder),
              ),
              child: const Icon(Icons.qr_code_scanner, size: 48, color: AppColor.gold),
            ),
            const SizedBox(height: 16),
            Text(
              'Arahkan QR booking pelanggan ke scanner, atau ketik kodenya.',
              style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              style: AppTextStyle.body,
              decoration: const InputDecoration(hintText: 'Kode QR booking'),
              onSubmitted: _submit,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColor.inkSoft),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Check-in')),
      ],
    );
  }
}
