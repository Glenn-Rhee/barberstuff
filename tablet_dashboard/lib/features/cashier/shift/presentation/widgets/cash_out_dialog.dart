import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/dialog_cancel_button.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';

// Catat uang yang diambil dari laci selama shift
Future<void> showCashOutDialog(BuildContext context) async {
  final shift = context.read<ShiftController>();
  if (!shift.isOpen) {
    AppToast.show(
      context,
      'Buka shift dulu sebelum mencatat kas keluar',
      error: true,
    );
    return;
  }

  final result = await showDialog<({int amount, String title, String note})>(
    context: context,
    builder: (_) => const _CashOutDialog(),
  );
  if (result == null || !context.mounted) return;

  final error = await shift.recordCashOut(
    amount: result.amount,
    title: result.title,
    description: result.note,
  );
  if (!context.mounted) return;
  AppToast.show(
    context,
    error ?? 'Kas keluar ${PriceFormat.full(result.amount)} dicatat',
    error: error != null,
  );
}

// Isi keperluan, nominal, dan catatan (opsional)
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
      title: const Text('Catat Kas Keluar', style: AppTextStyle.title),
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
              decoration: const InputDecoration(
                hintText: 'Contoh: beli pomade stok',
              ),
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
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
              ),
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
        const DialogCancelButton(),
        FilledButton(
          onPressed: _valid
              ? () => Navigator.pop(context, (
                  amount: _value,
                  title: _title.text.trim(),
                  note: _note.text.trim(),
                ))
              : null,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
