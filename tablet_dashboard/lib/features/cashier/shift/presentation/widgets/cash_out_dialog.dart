import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/app_form_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/money_field.dart';

// Modal "Pengeluaran Harian" dari aksi cepat: uang keluar dari laci,
// dicatat ke shift yang sedang buka (POST /transactions, tipe outcome)
Future<void> showCashOutDialog(BuildContext context) async {
  final shift = context.read<ShiftController>();
  if (!shift.isOpen) {
    AppToast.show(
      context,
      shift.enabled
          ? 'Buka shift dulu sebelum mencatat kas keluar'
          : shift.closedMessage,
      error: true,
    );
    return;
  }

  var amount = 0;
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _CashOutDialog(
      onSubmit: (value, note) {
        amount = value;
        return shift.recordCashOut(amount: value, title: note);
      },
    ),
  );
  if (saved != true || !context.mounted) return;
  AppToast.show(context, 'Kas keluar ${PriceFormat.full(amount)} dicatat');
}

class _CashOutDialog extends StatefulWidget {
  const _CashOutDialog({required this.onSubmit});

  final Future<String?> Function(int amount, String note) onSubmit;

  @override
  State<_CashOutDialog> createState() => _CashOutDialogState();
}

class _CashOutDialogState extends State<_CashOutDialog> {
  // Backend menolak nominal di bawah Rp 1.000
  static const _minAmount = 1000;

  final _amount = TextEditingController();
  final _note = TextEditingController();

  int get _value => ThousandsFormatter.parse(_amount.text);

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Pengeluaran Harian',
      subtitle: 'Masukkan pengeluaran operasional toko',
      canSubmit: _value >= _minAmount && _note.text.trim().isNotEmpty,
      onSubmit: () => widget.onSubmit(_value, _note.text.trim()),
      children: [
        const FieldLabel('Kategori Pengeluaran/Pemasukan', required: true),
        // Aksi cepat khusus pengeluaran, pemasukan nanti di tab Pembukuan
        DropdownButtonFormField<String>(
          initialValue: 'Pengeluaran',
          style: AppTextStyle.body.copyWith(color: AppColor.ink),
          items: const [
            DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
          ],
          onChanged: (_) {},
        ),
        const SizedBox(height: 14),
        const FieldLabel('Nominal', required: true),
        MoneyField(
          controller: _amount,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Metode Pembayaran', required: true),
        // Kas keluar diambil dari laci, jadi selalu tunai
        const SizedBox(
          width: double.infinity,
          child: Pill(
            label: 'Tunai',
            selected: true,
            style: PillStyle.soft,
            height: 44,
            onTap: null,
          ),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Keterangan', required: true),
        TextField(
          controller: _note,
          minLines: 3,
          maxLines: 3,
          style: AppTextStyle.body,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Contoh: beli air mineral dan tisu',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(
          'Minimal ${PriceFormat.full(_minAmount)}',
          style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
        ),
      ],
    );
  }
}
