import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/dialog_cancel_button.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';

// Buka shift dengan modal awal yang ada di laci
Future<void> showOpenShiftDialog(BuildContext context) async {
  final amount = await _showAmountDialog(
    context,
    title: 'Buka Shift Kasir',
    label: 'Modal awal di laci',
    confirmLabel: 'Buka Shift',
  );
  if (amount == null || !context.mounted) return;

  final shift = context.read<ShiftController>();
  final error = await shift.openShift(amount);
  if (!context.mounted) return;
  AppToast.show(
    context,
    error ?? 'Shift dibuka · modal ${PriceFormat.full(amount)}',
    error: error != null,
  );
}

// Tutup shift lalu tampilkan selisih uang dari backend
Future<void> showCloseShiftDialog(BuildContext context) async {
  final shift = context.read<ShiftController>();
  final session = shift.session;
  if (session == null) return;

  final amount = await _showAmountDialog(
    context,
    title: 'Tutup Shift Kasir',
    label: 'Uang tunai hasil hitung',
    confirmLabel: 'Tutup Shift',
    danger: true,
    note:
        'Seharusnya ada ${PriceFormat.full(session.expectedCash)} '
        '(modal ${PriceFormat.plain(session.openingBalance)} + tunai ${PriceFormat.plain(session.incomeCash)} '
        '- kas keluar ${PriceFormat.plain(session.outcome)}).\n\n'
        'Kas hanya bisa ditutup setelah toko lewat jam operasional.',
  );
  if (amount == null || !context.mounted) return;

  final result = await shift.closeShift(amount);
  if (!context.mounted) return;
  if (!result.ok) {
    // mis. "Toko masih dalam operasional tidak dapat menutup kas."
    AppToast.show(
      context,
      'Belum bisa tutup kas: ${result.error}',
      error: true,
    );
    return;
  }
  final label = switch (result.status) {
    'over' => 'lebih ${PriceFormat.full(result.difference.abs())}',
    'short' => 'kurang ${PriceFormat.full(result.difference.abs())}',
    _ => 'pas',
  };
  AppToast.show(context, 'Shift ditutup · uang $label');
}

// Dialog input nominal, backend menolak di bawah Rp 1.000
Future<int?> _showAmountDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String? note,
  bool danger = false,
}) {
  final controller = TextEditingController();
  return showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final amount = int.tryParse(controller.text) ?? 0;
        return AlertDialog(
          title: Text(title, style: AppTextStyle.title),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note != null) ...[
                  Text(
                    note,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(label, style: AppTextStyle.label),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyle.body,
                  decoration: const InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '0',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 6),
                Text(
                  'Minimal Rp 1.000',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColor.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            const DialogCancelButton(),
            FilledButton(
              onPressed: amount >= 1000
                  ? () => Navigator.pop(context, amount)
                  : null,
              style: danger
                  ? FilledButton.styleFrom(backgroundColor: AppColor.danger)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    ),
  );
}
