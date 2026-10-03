import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/services/export/file_share.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/domain/shift_report.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/provider/cash_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/widgets/history_detail_panel.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_history_entry.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/form/dropdown_chip.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Tab "History Harian": shift yang sudah ditutup per bulan
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  bool _exporting = false;
  String? _storeId;

  // Semua shift di bulan terpilih jadi satu PDF
  Future<void> _export() async {
    final history = context.read<CashHistoryController>();
    final storeName = context.read<StoreController>().current?.name;
    setState(() => _exporting = true);
    try {
      final entries = await history.allForMonth();
      if (entries.isEmpty) {
        if (mounted) {
          AppToast.show(context, 'Belum ada shift di bulan ini', error: true);
        }
        return;
      }
      final bytes = await ShiftReport.monthPdf(
        entries,
        month: history.month,
        storeName: storeName ?? entries.first.storeName,
      );
      final month = history.month.toIso8601String().substring(0, 7);
      await FileShare.pdf(bytes, 'laporan-pembukuan-$month.pdf');
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, error: true);
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Gagal membuat laporan: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CashHistoryController>();

    // Muat saat tab dibuka, dan ulang kalau admin ganti cabang
    final storeId = context.select<StoreController, String>((s) => s.storeId);
    if (storeId != _storeId) {
      _storeId = storeId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) history.load(storeId);
      });
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DropdownChip<DateTime>(
                    value: history.month,
                    options: history.months,
                    labelOf: DateFormatId.monthYear,
                    onChanged: history.setMonth,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppSearchField(
                      hint: 'Cari nama kasir...',
                      initialValue: history.query,
                      onChanged: history.setQuery,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: _exporting ? null : _export,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.ink,
                      ),
                      icon: _exporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Ekspor Laporan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Expanded(child: _HistoryTable()),
              const SizedBox(height: 12),
              PaginationBar(
                page: history.page - 1,
                pageCount: history.totalPages,
                onChanged: (page) => history.setPage(page + 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        const SizedBox(width: 320, child: HistoryDetailPanel()),
      ],
    );
  }
}

class _HistoryTable extends StatelessWidget {
  const _HistoryTable();

  static const _flex = [4, 4, 3, 3, 2];

  static Widget _cells(List<Widget> children) => Row(
    children: [
      for (final (i, child) in children.indexed)
        Expanded(
          flex: _flex[i],
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final history = context.watch<CashHistoryController>();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _cells([
              for (final label in const [
                'TANGGAL',
                'KASIR JAGA',
                'TUNAI',
                'NON-TUNAI',
                'AKSI',
              ])
                Text(
                  label,
                  style: AppTextStyle.label.copyWith(
                    fontSize: 10,
                    color: AppColor.inkSoft,
                  ),
                ),
            ]),
          ),
          const Divider(),
          Expanded(child: _body(history)),
        ],
      ),
    );
  }

  Widget _body(CashHistoryController history) {
    if (history.loading && history.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (history.error != null) {
      return ErrorRetryView(
        title: 'Gagal memuat history',
        message: history.error!,
        onRetry: history.refresh,
      );
    }
    if (history.entries.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'Belum ada shift ditutup',
        message: history.query.trim().isEmpty
            ? 'Shift yang sudah ditutup di '
                  '${DateFormatId.monthYear(history.month)} tampil di sini.'
            : 'Coba nama kasir lain.',
      );
    }

    return RefreshIndicator(
      onRefresh: history.refresh,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          for (final entry in history.entries)
            _HistoryRow(
              entry: entry,
              selected: history.selectedId == entry.id,
              onTap: () => history.select(entry),
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final CashHistoryEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppTextStyle.body.copyWith(fontSize: 12);

    return Material(
      color: selected ? AppColor.goldSoft : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColor.goldBorder : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: selected
              ? null
              : const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColor.border)),
                ),
          child: _HistoryTable._cells([
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatId.compactDate(entry.openedAt),
                  style: AppTextStyle.bodyBold.copyWith(fontSize: 12),
                ),
                Text(
                  ShiftReport.sessionHours(entry),
                  style: AppTextStyle.caption.copyWith(
                    fontSize: 10,
                    color: AppColor.inkSoft,
                  ),
                ),
              ],
            ),
            Text(
              entry.staffName ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text,
            ),
            Text(PriceFormat.full(entry.incomeCash), style: text),
            Text(PriceFormat.full(entry.incomeCashless), style: text),
            SizedBox(
              height: 30,
              child: selected
                  ? FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: AppTextStyle.label,
                      ),
                      child: const Text('Dipilih'),
                    )
                  : OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: AppTextStyle.label,
                      ),
                      child: const Text('Detail'),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
