import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/form/money_field.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// "Rekonsiliasi Kas": hitungan sistem vs uang fisik di laci, lalu tutup shift
class ReconciliationCard extends StatefulWidget {
  const ReconciliationCard({super.key, required this.session});

  final CashSession session;

  @override
  State<ReconciliationCard> createState() => _ReconciliationCardState();
}

class _ReconciliationCardState extends State<ReconciliationCard> {
  final _actual = TextEditingController();

  @override
  void dispose() {
    _actual.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    final actual = ThousandsFormatter.parse(_actual.text);
    final confirmed = await confirmDialog(
      context,
      title: 'Tutup shift?',
      message:
<<<<<<< HEAD
          'Uang fisik di laci ${PriceFormat.full(actual)}. Shift ditutup dan '
          'transaksi baru tidak bisa dicatat sampai shift dibuka lagi.',
=======
          'Uang di laci ${PriceFormat.full(actual)}. Transaksi baru '
          'tidak bisa dicatat sampai shift dibuka lagi.',
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
      confirmLabel: 'Tutup Shift',
      danger: true,
    );
    if (!confirmed || !mounted) return;

    final result = await context.read<ShiftController>().closeShift(actual);
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final busy = context.select<ShiftController, bool>((s) => s.busy);
    final filled = _actual.text.isNotEmpty;
    final actual = ThousandsFormatter.parse(_actual.text);
    final difference = actual - session.expectedCash;
    final (color, background, status) = switch (difference) {
      0 => (AppColor.success, AppColor.successSoft, 'Saldo sesuai'),
      > 0 => (AppColor.warning, AppColor.warningSoft, 'Uang lebih'),
      _ => (AppColor.danger, AppColor.dangerSoft, 'Uang kurang'),
    };

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('REKONSILIASI KAS', style: AppTextStyle.bodyBold),
          const SizedBox(height: 16),
          _Line('Saldo Awal', PriceFormat.full(session.openingBalance)),
          _Line(
            '+ Pendapatan Tunai',
            PriceFormat.full(session.incomeCash),
            color: AppColor.success,
          ),
          _Line(
            '+ Pendapatan Non Tunai',
            PriceFormat.full(session.incomeCashless),
            color: AppColor.info,
            note: 'masuk rekening',
          ),
          _Line(
            '- Pengeluaran',
            PriceFormat.full(session.outcome),
            color: AppColor.danger,
          ),
          const Divider(height: 20),
          _Line(
            'Saldo Tunai Seharusnya',
            PriceFormat.full(session.expectedCash),
            bold: true,
          ),
          const SizedBox(height: 20),
          const Text('Input Aktual Kasir', style: AppTextStyle.label),
          Text(
            '(dari laci kasir / uang fisik)',
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
          const SizedBox(height: 6),
          MoneyField(controller: _actual, onChanged: (_) => setState(() {})),
          if (filled) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    difference == 0 ? Icons.check_circle : Icons.error,
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selisih',
                          style: AppTextStyle.caption.copyWith(color: color),
                        ),
                        Text(
                          PriceFormat.full(difference),
                          style: AppTextStyle.bodyBold.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    status,
                    style: AppTextStyle.label.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: filled && actual >= 1000 && !busy ? _close : null,
            child: const Text('TUTUP SHIFT'),
          ),
          const SizedBox(height: 4),
          Text(
            'Kas hanya bisa ditutup setelah toko lewat jam operasional.',
            textAlign: TextAlign.center,
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(
    this.label,
    this.value, {
    this.color,
    this.bold = false,
    this.note,
  });

  final String label;
  final String value;
  final Color? color;
  final bool bold;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final style = (bold ? AppTextStyle.bodyBold : AppTextStyle.body).copyWith(
      fontSize: 13,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: label,
                style: style,
                children: [
                  if (note != null)
                    TextSpan(
                      text: ' ($note)',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}
