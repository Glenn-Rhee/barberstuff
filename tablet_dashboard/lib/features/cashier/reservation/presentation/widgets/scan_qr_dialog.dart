import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/dialog_cancel_button.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';

// Check-in booking pakai kode QR (PATCH /staff/booking/checkin/{qr}).
// Scanner USB/Bluetooth mengetik seperti keyboard, jadi cukup TextField fokus.
// [initialCode] untuk isi awal kolom
Future<void> scanQrAndCheckIn(
  BuildContext context, {
  String? initialCode,
}) async {
  final code = await showDialog<String>(
    context: context,
    builder: (_) => _ScanQrDialog(initialCode: initialCode),
  );
  if (code == null || code.trim().isEmpty || !context.mounted) return;

  final bookings = context.read<BookingsController>();
  final error = await bookings.checkIn(code.trim());
  if (!context.mounted) return;
  if (error != null) {
    AppToast.show(context, error, error: true);
    return;
  }

  context.read<NavigationController>().openOrder(OrderTab.reservation);
  await bookings.refresh();
  if (context.mounted) AppToast.show(context, 'Check-in berhasil');
}

class _ScanQrDialog extends StatefulWidget {
  const _ScanQrDialog({this.initialCode});

  final String? initialCode;

  @override
  State<_ScanQrDialog> createState() => _ScanQrDialogState();
}

class _ScanQrDialogState extends State<_ScanQrDialog> {
  late final _controller = TextEditingController(text: widget.initialCode);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit([String? value]) =>
      Navigator.pop(context, value ?? _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan QR Booking', style: AppTextStyle.title),
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
              child: const Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: AppColor.gold,
              ),
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
        const DialogCancelButton(),
        FilledButton(onPressed: _submit, child: const Text('Check-in')),
      ],
    );
  }
}
