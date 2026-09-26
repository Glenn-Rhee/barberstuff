import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../shared/widgets/common.dart';
import '../provider/shift_controller.dart';

/// Opens the cash session with the money already in the drawer.
Future<void> showOpenShiftDialog(BuildContext context) async {
  final amount = await _amountDialog(
    context,
    title: 'Buka Shift Kasir',
    label: 'Modal awal di laci',
    confirmLabel: 'Buka Shift',
  );
  if (amount == null || !context.mounted) return;

  final shift = context.read<ShiftController>();
  final error = await shift.openShift(amount);
  if (!context.mounted) return;
  AppToast.show(context, error ?? 'Shift dibuka · modal ${PriceFormat.full(amount)}', error: error != null);
}

/// Closes the session and reports the difference the backend calculated.
Future<void> showCloseShiftDialog(BuildContext context) async {
  final shift = context.read<ShiftController>();
  final session = shift.session;
  if (session == null) return;

  final amount = await _amountDialog(
    context,
    title: 'Tutup Shift Kasir',
    label: 'Uang tunai hasil hitung',
    confirmLabel: 'Tutup Shift',
    danger: true,
    note:
        'Seharusnya ada ${PriceFormat.full(session.expectedCash)} '
        '(modal ${PriceFormat.plain(session.saldoBegin)} + tunai ${PriceFormat.plain(session.incomeCash)} '
        '- kas keluar ${PriceFormat.plain(session.outcome)}).\n\n'
        'Kas hanya bisa ditutup setelah toko lewat jam operasional.',
  );
  if (amount == null || !context.mounted) return;

  final result = await shift.closeShift(amount);
  if (!context.mounted) return;
  if (!result.ok) {
    // e.g. "Toko masih dalam operasional tidak dapat menutup kas."
    AppToast.show(context, 'Belum bisa tutup kas: ${result.error}', error: true);
    return;
  }
  final label = switch (result.status) {
    'over' => 'lebih ${PriceFormat.full(result.difference.abs())}',
    'short' => 'kurang ${PriceFormat.full(result.difference.abs())}',
    _ => 'pas',
  };
  AppToast.show(context, 'Shift ditutup · uang $label');
}

Future<void> showCashOutDialog(BuildContext context) async {
  final shift = context.read<ShiftController>();
  if (!shift.isOpen) {
    AppToast.show(context, 'Buka shift dulu sebelum mencatat kas keluar', error: true);
    return;
  }

  final result = await showDialog<({int amount, String title, String note})>(
    context: context,
    builder: (_) => const _CashOutDialog(),
  );
  if (result == null || !context.mounted) return;

  final error = await shift.recordCashOut(amount: result.amount, title: result.title, description: result.note);
  if (!context.mounted) return;
  AppToast.show(context, error ?? 'Kas keluar ${PriceFormat.full(result.amount)} dicatat', error: error != null);
}

/// Shared money prompt; the backend rejects anything under Rp 1.000.
Future<int?> _amountDialog(
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
          title: Text(title, style: AppTextStyle.sectionTitle),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note != null) ...[Text(note, style: AppTextStyle.caption), const SizedBox(height: 12)],
                Text(label, style: AppTextStyle.label),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyle.body,
                  decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 6),
                Text('Minimal Rp 1.000', style: AppTextStyle.caption),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppColor.inkSoft),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: amount >= 1000 ? () => Navigator.pop(context, amount) : null,
              style: danger ? FilledButton.styleFrom(backgroundColor: AppColor.danger) : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    ),
  );
}

class _CashOutDialog extends StatefulWidget {
  const _CashOutDialog();

  @override
  State<_CashOutDialog> createState() => _CashOutDialogState();
}

class _CashOutDialogState extends State<_CashOutDialog> {
  final _amount = TextEditingController();
  final _title = TextEditingController();
  final _note = TextEditingController();

  int get _value => int.tryParse(_amount.text) ?? 0;
  bool get _valid => _value >= 1000 && _title.text.trim().isNotEmpty;

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catat Kas Keluar', style: AppTextStyle.sectionTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keperluan', style: AppTextStyle.label),
            const SizedBox(height: 6),
            TextField(
              controller: _title,
              autofocus: true,
              style: AppTextStyle.body,
              decoration: const InputDecoration(hintText: 'Contoh: beli pomade stok'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const Text('Nominal', style: AppTextStyle.label),
            const SizedBox(height: 6),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyle.body,
              decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const Text('Catatan (opsional)', style: AppTextStyle.label),
            const SizedBox(height: 6),
            TextField(
              controller: _note,
              style: AppTextStyle.body,
              decoration: const InputDecoration(hintText: 'Detail tambahan'),
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
        FilledButton(
          onPressed: _valid
              ? () => Navigator.pop(context, (amount: _value, title: _title.text.trim(), note: _note.text.trim()))
              : null,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
