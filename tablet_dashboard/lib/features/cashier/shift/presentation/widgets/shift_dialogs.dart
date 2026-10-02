import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/app_form_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/money_field.dart';

// Backend menolak nominal di bawah Rp 1.000
const _minAmount = 1000;

// Modal "Saldo Awal": buka shift dengan uang yang sudah ada di laci
Future<void> showOpenShiftDialog(BuildContext context) async {
  final shift = context.read<ShiftController>();
  var amount = 0;
  final opened = await showDialog<bool>(
    context: context,
    builder: (_) => _AmountDialog(
      title: 'Saldo Awal',
      subtitle: 'Masukkan Saldo Awal operasional toko',
      label: 'Nominal',
      onSubmit: (value) {
        amount = value;
        return shift.openShift(value);
      },
    ),
  );
  if (opened != true || !context.mounted) return;
  AppToast.show(
    context,
    'Shift dibuka · saldo awal ${PriceFormat.full(amount)}',
  );

  // Kasir baru dapat nama toko dari riwayat kas setelah shift pertama
  final store = context.read<StoreController>();
  final profile = context.read<SessionController>().profile;
  if (store.current?.name == null && profile != null) store.load(profile);
}

// Modal "Tutup Shift": hitung uang di laci, backend yang hitung selisihnya
Future<void> showCloseShiftDialog(BuildContext context) async {
  final shift = context.read<ShiftController>();
  final session = shift.session;
  if (session == null) return;

  CloseShiftResult? result;
  final closed = await showDialog<bool>(
    context: context,
    builder: (_) => _AmountDialog(
      title: 'Tutup Shift',
      subtitle: 'Hitung uang tunai di laci sebelum menutup shift',
      label: 'Uang tunai hasil hitung',
      submitLabel: 'Tutup Shift',
      danger: true,
      note:
          'Seharusnya ada ${PriceFormat.full(session.expectedCash)} '
          '(saldo awal ${PriceFormat.plain(session.openingBalance)} + tunai '
          '${PriceFormat.plain(session.incomeCash)} - kas keluar '
          '${PriceFormat.plain(session.outcome)}). Kas hanya bisa ditutup '
          'setelah toko lewat jam operasional.',
      onSubmit: (value) async {
        result = await shift.closeShift(value);
        // mis. "Toko masih dalam operasional tidak dapat menutup kas."
        return result!.ok ? null : 'Belum bisa tutup kas: ${result!.error}';
      },
    ),
  );
  final done = result;
  if (closed != true || done == null || !context.mounted) return;
  final label = switch (done.status) {
    'over' => 'lebih ${PriceFormat.full(done.difference.abs())}',
    'short' => 'kurang ${PriceFormat.full(done.difference.abs())}',
    _ => 'pas',
  };
  AppToast.show(context, 'Shift ditutup · uang $label');
}

// Modal isi satu nominal (saldo awal / uang hasil hitung)
class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.onSubmit,
    this.note,
    this.submitLabel = 'Simpan',
    this.danger = false,
  });

  final String title;
  final String subtitle;
  final String label;
  final String? note;
  final String submitLabel;
  final bool danger;
  final Future<String?> Function(int amount) onSubmit;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _amount = TextEditingController();

  int get _value => ThousandsFormatter.parse(_amount.text);

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: widget.title,
      subtitle: widget.subtitle,
      submitLabel: widget.submitLabel,
      danger: widget.danger,
      canSubmit: _value >= _minAmount,
      onSubmit: () => widget.onSubmit(_value),
      children: [
        if (widget.note != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(widget.note!, style: AppTextStyle.caption),
          ),
          const SizedBox(height: 16),
        ],
        FieldLabel(widget.label, required: true),
        MoneyField(
          controller: _amount,
          autofocus: true,
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
