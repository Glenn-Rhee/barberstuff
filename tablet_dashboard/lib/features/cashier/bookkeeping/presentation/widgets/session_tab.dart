import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/widgets/reconciliation_card.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/widgets/cancel_booking_dialog.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/cash_entry_dialog.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/shift_dialogs.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tab "Sesi Kasir": shift yang sedang buka, semua dari GET /cash-sessions
class SessionTab extends StatefulWidget {
  const SessionTab({super.key});

  @override
  State<SessionTab> createState() => _SessionTabState();
}

class _SessionTabState extends State<SessionTab> {
  @override
  void initState() {
    super.initState();
    // Angka shift terbaru tiap tab dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final shift = context.read<ShiftController>();
      shift.refresh(silent: shift.session != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftController>();
    final session = shift.session;

    if (!shift.enabled) {
      return const EmptyState(
        icon: Icons.lock_outline,
        title: 'Sesi kasir khusus akun kasir',
        message: 'Lihat rekap shift yang sudah ditutup di History Harian.',
      );
    }
    if (shift.loading && session == null) return const _SessionSkeleton();
    if (session == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shift.error != null) ...[
              ErrorBar(message: shift.error!, onRetry: shift.refresh),
              const SizedBox(height: 16),
            ],
            const EmptyState(
              icon: Icons.point_of_sale_outlined,
              title: 'Shift belum dibuka',
              message: 'Isi saldo awal laci untuk mulai mencatat kas hari ini.',
            ),
            FilledButton(
              onPressed: shift.busy ? null : () => showOpenShiftDialog(context),
              child: const Text('Buka Shift Kasir'),
            ),
          ],
        ),
      );
    }

    final expenses = [
      for (final t in session.transactions)
        if (t.type == TransactionType.outcome) t,
    ];
    // Yang sudah di-void tetap tampil (dicoret) biar jejaknya kelihatan
    final sales = [
      for (final t in session.transactions)
        if (t.type == TransactionType.income) t,
    ];

    return RefreshIndicator(
      onRefresh: shift.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MoneyCard(
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColor.inkSoft,
                    title: 'Saldo Awal',
                    caption: '(Manual)',
                    value: session.openingBalance,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MoneyCard(
                    asset: AppAsset.cashIcon,
                    color: AppColor.success,
                    title: 'Pendapatan Tunai',
                    caption: '(Otomatis dari Kasir)',
                    value: session.incomeCash,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MoneyCard(
                    asset: AppAsset.cashlessIcon,
                    color: AppColor.info,
                    title: 'Pendapatan Non Tunai',
                    caption: '(Otomatis dari Kasir)',
                    value: session.incomeCashless,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ExpenseCard(expenses: expenses),
                      const SizedBox(height: 16),
                      _SalesCard(sales: sales),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 300,
                  child: ReconciliationCard(session: session),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({
    this.icon,
    this.asset,
    required this.color,
    required this.title,
    required this.caption,
    required this.value,
  });

  final IconData? icon;
  final String? asset;
  final Color color;
  final String title;
  final String caption;
  final int value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: asset != null
                    ? AppIcon(asset!, size: 18, color: color)
                    : Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.label),
                    Text(
                      caption,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(PriceFormat.full(value), style: AppTextStyle.h1),
          ),
        ],
      ),
    );
  }
}

// Nominal transaksi yang sudah di-void: dicoret dan pudar
final _voidedStyle = AppTextStyle.body.copyWith(
  color: AppColor.inkFaint,
  decoration: TextDecoration.lineThrough,
);

// Tabel "Pengeluaran Harian" + tombol tambah (modal Catat Kas)
class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expenses});

  final List<CashTransaction> expenses;

  static const _flex = [1, 5, 3, 4];

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
    final total = expenses.fold(0, (sum, t) => t.voided ? sum : sum + t.amount);
    final head = AppTextStyle.label.copyWith(
      fontSize: 11,
      color: AppColor.inkSoft,
    );

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('PENGELUARAN HARIAN', style: AppTextStyle.bodyBold),
              ),
              FilledButton.icon(
                onPressed: () => showCashEntryDialog(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColor.ink,
                  minimumSize: const Size(0, 36),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _cells([
            Text('No', style: head),
            Text('Judul Pengeluaran', style: head),
            Text('Nominal', style: head),
            Text('Catatan', style: head),
          ]),
          const Divider(height: 16),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Belum ada pengeluaran di shift ini.',
                style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              ),
            ),
          for (final (index, t) in expenses.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColor.border)),
              ),
              child: _cells([
                Text('${index + 1}', style: AppTextStyle.body),
                Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body,
                ),
                Text(
                  PriceFormat.full(t.amount),
                  style: t.voided ? _voidedStyle : AppTextStyle.body,
                ),
                Text(
                  t.voided
                      ? 'Dibatalkan: ${t.description ?? '-'}'
                      : t.description ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body.copyWith(
                    color: t.voided ? AppColor.danger : AppColor.inkSoft,
                  ),
                ),
              ]),
            ),
          const SizedBox(height: 10),
          _cells([
            const SizedBox.shrink(),
            const Text('Total Pengeluaran', style: AppTextStyle.bodyBold),
            Text(PriceFormat.full(total), style: AppTextStyle.bodyBold),
            const SizedBox.shrink(),
          ]),
        ],
      ),
    );
  }
}

// "Transaksi Hari Ini": pemasukan dari pembayaran booking
class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.sales});

  final List<CashTransaction> sales;

  static const _shown = 5;

  void _showAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaksi Hari Ini', style: AppTextStyle.title),
        content: SizedBox(
          width: 480,
          height: 420,
          child: ListView(
            children: [for (final t in sales) _SaleTile(transaction: t)],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('TRANSAKSI HARI INI', style: AppTextStyle.bodyBold),
              ),
              if (sales.length > _shown)
                TextButton(
                  onPressed: () => _showAll(context),
                  child: Text('Lihat Semua (${sales.length})'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (sales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Belum ada transaksi di shift ini.',
                style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              ),
            ),
          for (final t in sales.reversed.take(_shown))
            _SaleTile(transaction: t),
        ],
      ),
    );
  }
}

class _SaleTile extends StatefulWidget {
  const _SaleTile({required this.transaction});

  final CashTransaction transaction;

  @override
  State<_SaleTile> createState() => __SaleTileState();
}

class __SaleTileState extends State<_SaleTile> {
  // Batalkan booking (Completed)
  Future<void> _cancelWhenCompleted(CashTransaction transaction) async {
    final transactions = context.read<ShiftController>();
    final cancelled = await showCancelBookingDialog(
      context,
      onSubmit: (reason) => transactions.cancel(transaction, reason),
    );

    if (!cancelled || !mounted) return;
    // Booking-nya ikut jadi Cancel di server
    context.read<BookingsController>().refresh();
    context.read<DashboardController>().refresh();
    AppToast.show(context, 'Pesanan dibatalkan');
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final cash = transaction.paymentType == PaymentType.cash;
    final at = transaction.createdAt;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyBold,
                ),
                Text(
                  at == null ? '-' : DateFormatId.time(at),
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
                if (transaction.voided)
                  Text(
                    'Alasan: ${transaction.description ?? '-'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColor.danger,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormat.full(transaction.amount),
                style: transaction.voided
                    ? _voidedStyle.copyWith(fontWeight: FontWeight.w600)
                    : AppTextStyle.bodyBold,
              ),
              if (transaction.voided)
                const StatusBadge(
                  label: 'Dibatalkan',
                  color: AppColor.danger,
                  background: AppColor.dangerSoft,
                )
              else
                StatusBadge(
                  label: cash ? 'Tunai' : 'Non Tunai',
                  color: cash ? AppColor.success : AppColor.info,
                  background: cash ? AppColor.successSoft : AppColor.infoSoft,
                ),
            ],
          ),
          // Yang sudah di-void tidak bisa dibatalkan lagi
          if (!transaction.voided) ...[
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () => _cancelWhenCompleted(transaction),
              child: Image.asset(AppAsset.trashIcon, height: 20),
            ),
          ] else
            const SizedBox(width: 35),
        ],
      ),
    );
  }
}

// Kerangka tab Sesi Kasir: tiga kartu angka, tabel, dan rekonsiliasi
class _SessionSkeleton extends StatelessWidget {
  const _SessionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 124, lines: 2)),
              SizedBox(width: 16),
              Expanded(child: SkeletonCard(height: 124, lines: 2)),
              SizedBox(width: 16),
              Expanded(child: SkeletonCard(height: 124, lines: 2)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkeletonCard(height: 220, lines: 5),
                    SizedBox(height: 16),
                    SkeletonCard(height: 180, lines: 4),
                  ],
                ),
              ),
              SizedBox(width: 16),
              SizedBox(width: 300, child: SkeletonCard(height: 416, lines: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
