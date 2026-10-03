import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/services/export/file_share.dart';
import 'package:tablet_dashboard/core/services/printer/receipt_logo.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/domain/shift_report.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/provider/cash_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_history_entry.dart';
import 'package:tablet_dashboard/shared/dialogs/print_with_retry.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Panel kanan History Harian: rekap satu shift + cetak / PDF
class HistoryDetailPanel extends StatelessWidget {
  const HistoryDetailPanel({super.key});

  Future<void> _print(BuildContext context, CashHistoryEntry entry) async {
    final printed = await printWithRetry(
      context,
      ShiftReport.escPos(entry, logo: ReceiptLogo.cached),
    );
    if (printed && context.mounted) {
      AppToast.show(context, 'Ringkasan shift dicetak');
    }
  }

  Future<void> _download(BuildContext context, CashHistoryEntry entry) async {
    try {
      final bytes = await ShiftReport.dayPdf(entry);
      final date = entry.openedAt.toIso8601String().substring(0, 10);
      await FileShare.pdf(bytes, 'pembukuan-$date.pdf');
    } catch (e) {
      if (context.mounted) {
        AppToast.show(context, 'Gagal membuat PDF: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CashHistoryController>();
    final entry = history.selected;

    if (entry == null) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Pilih shift',
          message: 'Tap salah satu tanggal untuk melihat rekap shift.',
        ),
      );
    }

    final (color, background) = switch (entry.difference) {
      0 => (AppColor.success, AppColor.successSoft),
      > 0 => (AppColor.warning, AppColor.warningSoft),
      _ => (AppColor.danger, AppColor.dangerSoft),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Detail Pembukuan', style: AppTextStyle.title),
              ),
              IconButton(
                tooltip: 'Tutup detail',
                visualDensity: VisualDensity.compact,
                onPressed: () => history.select(null),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormatId.longDate(entry.openedAt),
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ),
              StatusBadge(
                label: ShiftReport.statusText(entry),
                color: color,
                background: background,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Info('Waktu Sesi', ShiftReport.sessionHours(entry)),
                  _Info(
                    'Kasir Jaga',
                    entry.staffName ?? '-',
                    sub: entry.storeName,
                  ),
                  const SizedBox(height: 12),
                  const Text('Ringkasan', style: AppTextStyle.bodyBold),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _Tile('Saldo Awal', entry.openingBalance),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Tile(
                          'Tunai',
                          entry.incomeCash,
                          color: AppColor.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _Tile(
                          'Non Tunai',
                          entry.incomeCashless,
                          color: AppColor.info,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Tile(
                          'Pengeluaran',
                          entry.outcome,
                          color: AppColor.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Info('Total Pendapatan', PriceFormat.full(entry.income)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Info(
                          'Saldo Tunai Seharusnya',
                          PriceFormat.full(entry.expectedCash),
                        ),
                        _Info(
                          'Input Fisik Aktual Kasir',
                          PriceFormat.full(entry.actualCash),
                        ),
                        _Info(
                          'Selisih',
                          PriceFormat.full(entry.difference),
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Non-tunai masuk rekening, tidak dihitung di fisik '
                          'laci.',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColor.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _print(context, entry),
                  icon: const Icon(Icons.print_outlined, size: 16),
                  label: const Text('Cetak'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _download(context, entry),
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value, {this.sub, this.color});

  final String label;
  final String value;
  final String? sub;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: AppTextStyle.label.copyWith(color: color),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    textAlign: TextAlign.end,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.inkFaint,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value, {this.color});

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              PriceFormat.full(value),
              style: AppTextStyle.bodyBold.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
