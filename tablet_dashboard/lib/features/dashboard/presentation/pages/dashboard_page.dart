import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation_controller.dart';
import '../../../../app/scan_barcode.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/store_widgets.dart';
import '../../../auth/presentation/provider/session_controller.dart';
import '../../../cashier/presentation/provider/catalog_controller.dart';
import '../../../reservation/presentation/provider/bookings_controller.dart';
import '../provider/shift_controller.dart';
import '../widgets/shift_dialogs.dart';

/// Today's till: everything here comes from the open cash session and the
/// store's bookings, so it is empty until the shift is opened.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _refresh(BuildContext context) async {
    context.read<ShiftController>().refresh();
    context.read<BookingsController>().refresh();
    context.read<CatalogController>().loadCapsters();
  }

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftController>();
    final session = shift.session;
    final name = context.select<SessionController, String>((s) => s.profile?.name ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dashboard > Ringkasan', style: AppTextStyle.caption),
                      Text(
                        'Selamat Datang, ${name.split(' ').first}!',
                        style: AppTextStyle.pageTitle.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Muat ulang data',
                  onPressed: () => _refresh(context),
                  icon: const Icon(Icons.refresh, size: 20),
                ),
                const SizedBox(width: 8),
                const ShiftStatusChip(filled: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (shift.error != null) ...[
            _ErrorBar(message: shift.error!, onRetry: () => _refresh(context)),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_basket_outlined,
                  color: AppColor.gold,
                  title: 'Transaksi Hari Ini',
                  value: session == null ? '—' : '${session.sales.length}',
                  caption: session == null
                      ? 'Shift belum dibuka'
                      : '${session.cashSales} tunai · ${session.cashlessSales} non-tunai',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.show_chart,
                  color: AppColor.success,
                  title: 'Penjualan Hari Ini',
                  value: session == null ? '—' : PriceFormat.full(session.income),
                  caption: session == null
                      ? 'Shift belum dibuka'
                      : 'Tunai ${PriceFormat.plain(session.incomeCash)} · Non tunai ${PriceFormat.plain(session.incomeCashless)}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_down,
                  color: AppColor.danger,
                  title: 'Kas Keluar',
                  value: session == null ? '—' : PriceFormat.full(session.outcome),
                  caption: session == null
                      ? 'Shift belum dibuka'
                      : 'Modal awal ${PriceFormat.plain(session.saldoBegin)}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColor.info,
                  title: 'Kas di Laci',
                  value: session == null ? '—' : PriceFormat.full(session.expectedCash),
                  caption: session == null ? 'Shift belum dibuka' : 'Perhitungan sistem',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _QuickActions(),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _UpcomingBookings()),
              SizedBox(width: 16),
              SizedBox(width: 340, child: Column(children: [_ShiftCard(), SizedBox(height: 16), _CapsterList()])),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColor.surfaceMuted, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.caption),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: AppTextStyle.stat),
                ),
                Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final open = context.select<ShiftController, bool>((s) => s.isOpen);
    final style = OutlinedButton.styleFrom(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AKSI CEPAT', style: AppTextStyle.bodyStrong),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: style,
                  onPressed: () => scanBarcode(context),
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text('Scan QR Booking'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: style,
                  onPressed: open ? () => showCashOutDialog(context) : null,
                  icon: const Icon(Icons.trending_down, size: 20),
                  label: const Text('Catat Kas Keluar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: style,
                  onPressed: () => context.read<NavigationController>().openKasir(KasirTab.langsung),
                  icon: const Icon(Icons.point_of_sale_outlined, size: 20),
                  label: const Text('Buka Kasir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingBookings extends StatelessWidget {
  const _UpcomingBookings();

  static const _flex = [2, 4, 4, 3, 3];

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>();
    final upcoming = bookings.upcoming.take(5).toList();

    Widget cells(List<Widget> children) => Row(
      children: [
        for (final (i, child) in children.indexed)
          Expanded(
            flex: _flex[i],
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Booking Berikutnya', style: AppTextStyle.sectionTitle),
                    Text('Pelanggan yang belum selesai dilayani.', style: AppTextStyle.caption),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.read<NavigationController>().openKasir(KasirTab.reservasi),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('Lihat Semua'), Icon(Icons.chevron_right, size: 18)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColor.surfaceMuted, borderRadius: BorderRadius.circular(8)),
            child: cells([
              for (final label in const ['WAKTU', 'PELANGGAN', 'LAYANAN', 'CAPSTER', 'STATUS'])
                Text(label, style: AppTextStyle.overline),
            ]),
          ),
          if (bookings.loading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (bookings.error != null)
            _ErrorBar(message: bookings.error!, onRetry: bookings.refresh)
          else if (upcoming.isEmpty)
            const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Belum ada booking',
              message: 'Booking yang masuk hari ini akan tampil di sini.',
            ),
          for (final booking in upcoming)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColor.border)),
              ),
              child: cells([
                Text(
                  booking.scheduledAt == null ? '-' : DateFormatId.time(booking.scheduledAt!),
                  style: AppTextStyle.bodyStrong,
                ),
                Text(
                  booking.customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyStrong,
                ),
                Text(
                  booking.services.map((s) => s.item.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body,
                ),
                Text(booking.capster.name, style: AppTextStyle.body.copyWith(color: AppColor.inkSoft)),
                StatusBadge.booking(booking.status),
              ]),
            ),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard();

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftController>();
    final session = shift.session;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Status Operasional', style: AppTextStyle.sectionTitle),
          const SizedBox(height: 12),
          Text(session == null ? 'Shift kasir belum dibuka' : 'Shift sedang berjalan', style: AppTextStyle.caption),
          Text(
            session == null ? 'Buka shift untuk mulai transaksi' : 'Modal awal ${PriceFormat.full(session.saldoBegin)}',
            style: AppTextStyle.bodyStrong.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (session == null)
            FilledButton(
              onPressed: shift.busy ? null : () => showOpenShiftDialog(context),
              child: const Text('Buka Shift Kasir'),
            )
          else
            OutlinedButton(
              style: dangerOutlinedStyle(),
              onPressed: shift.busy ? null : () => showCloseShiftDialog(context),
              child: const Text('Tutup Shift Kasir'),
            ),
        ],
      ),
    );
  }
}

class _CapsterList extends StatelessWidget {
  const _CapsterList();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final capsters = catalog.activeCapsters;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Capster Toko', style: AppTextStyle.sectionTitle)),
              Text('${capsters.length} aktif', style: AppTextStyle.label.copyWith(color: AppColor.success)),
            ],
          ),
          const SizedBox(height: 12),
          if (catalog.loadingCapsters)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (catalog.capsterError != null)
            _ErrorBar(message: catalog.capsterError!, onRetry: catalog.loadCapsters)
          else
            for (final capster in capsters.take(6))
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColor.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    PersonAvatar(name: capster.name, photo: capster.photoUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        capster.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyStrong,
                      ),
                    ),
                    if (capster.rating > 0) ...[
                      const Icon(Icons.star_rounded, size: 14, color: AppColor.gold),
                      Text(capster.rating.toStringAsFixed(1), style: AppTextStyle.caption),
                    ],
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _ErrorBar extends StatelessWidget {
  const _ErrorBar({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColor.dangerSoft, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: AppColor.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: AppTextStyle.label.copyWith(color: AppColor.danger)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
