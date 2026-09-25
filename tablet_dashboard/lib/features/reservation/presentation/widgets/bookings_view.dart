import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../data/api/barberstuff_api.dart';
import '../../../../shared/models/person.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pagination_bar.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../cashier/presentation/pages/kasir_page.dart';
import '../../domain/booking.dart';
import '../provider/bookings_controller.dart';
import 'booking_panel.dart';

/// "Dari Reservasi": the store's bookings from `GET /booking`.
class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  static const _flex = [7, 3, 5, 4, 4];

  static Widget cells(List<Widget> children, {Widget trailing = const SizedBox(width: 24)}) => Row(
    children: [
      for (final (i, child) in children.indexed)
        Expanded(
          flex: _flex[i],
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      trailing,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: KasirTabs()),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      hint: 'Cari pelanggan atau layanan...',
                      initialValue: bookings.query,
                      onChanged: bookings.setQuery,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const _StatusFilter(),
                  const SizedBox(width: 12),
                  IconButton.outlined(
                    tooltip: 'Muat ulang',
                    onPressed: bookings.refresh,
                    icon: const Icon(Icons.refresh, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                        child: cells([
                          for (final label in const ['PELANGGAN', 'JADWAL', 'LAYANAN', 'CAPSTER', 'STATUS'])
                            Text(label, style: AppTextStyle.overline),
                        ]),
                      ),
                      const Divider(),
                      Expanded(child: _list(bookings)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PaginationBar(
                page: bookings.page - 1, // the API pages from 1
                pageCount: bookings.totalPages,
                onChanged: (page) => bookings.setPage(page + 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        const SizedBox(width: kasirPanelWidth, child: BookingPanel()),
      ],
    );
  }

  Widget _list(BookingsController bookings) {
    if (bookings.loading) return const Center(child: CircularProgressIndicator());
    if (bookings.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: AppColor.inkFaint),
            const SizedBox(height: 12),
            Text('Gagal memuat booking', style: AppTextStyle.bodyStrong),
            const SizedBox(height: 2),
            Text(bookings.error!, style: AppTextStyle.caption, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: bookings.refresh, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (bookings.bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Belum ada booking',
        message: 'Booking dari aplikasi pelanggan akan muncul di sini.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final booking in bookings.bookings)
          _BookingRow(
            booking: booking,
            selected: bookings.selectedId == booking.id,
            onTap: () => bookings.toggle(booking),
          ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking, required this.selected, required this.onTap});

  final Booking booking;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final main = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: BookingsView.cells(
        [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: selected ? AppColor.goldBorder : AppColor.surfaceMuted,
                child: Text(initialsOf(booking.customer.name), style: AppTextStyle.overline),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyStrong.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          Text(
            booking.scheduledAt == null ? '-' : DateFormatId.time(booking.scheduledAt!),
            style: AppTextStyle.bodyStrong,
          ),
          Text(
            booking.services.map((s) => s.item.name).join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body.copyWith(fontSize: 12),
          ),
          Text(
            booking.capster.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body.copyWith(fontSize: 12),
          ),
          StatusBadge.booking(booking.status),
        ],
        trailing: SizedBox(
          width: 24,
          child: Icon(selected ? Icons.keyboard_arrow_up : Icons.chevron_right, color: AppColor.inkSoft, size: 20),
        ),
      ),
    );

    if (!selected) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColor.border)),
          ),
          child: main,
        ),
      );
    }

    final customer = booking.customer;
    Widget detail(String label, String value, {Color? color}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.overline.copyWith(fontSize: 9)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.label.copyWith(color: color),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.goldSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.goldBorder),
      ),
      child: Column(
        children: [
          InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: main),
          const Divider(color: AppColor.goldBorder, indent: 12, endIndent: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                detail('TELEPON', customer.phone ?? '-'),
                detail(
                  'MEMBERSHIP',
                  customer.premiumType ?? 'Non Member',
                  color: customer.isMember ? AppColor.gold : AppColor.inkSoft,
                ),
                detail('POIN PELANGGAN', '${PriceFormat.plain(customer.memberPoints)} poin'),
                detail('LAYANAN FAVORIT', customer.favoriteService ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter();

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>();

    // -1 means "Semua Status"; PopupMenuButton treats a null value as cancel.
    return PopupMenuButton<int>(
      tooltip: 'Filter status',
      position: PopupMenuPosition.under,
      onSelected: (index) => bookings.setStatus(index < 0 ? null : BookingStatus.values[index]),
      itemBuilder: (_) => [
        const PopupMenuItem(value: -1, child: Text('Semua Status', style: AppTextStyle.body)),
        for (final value in BookingStatus.values)
          PopupMenuItem(
            value: value.index,
            child: Text(value.label, style: AppTextStyle.body),
          ),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(bookings.status?.label ?? 'Semua Status', style: AppTextStyle.body),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColor.inkSoft),
          ],
        ),
      ),
    );
  }
}

/// Adds a service to an existing booking (`POST /staff/booking/item`).
Future<void> addServiceToBooking(BuildContext context, Booking booking, String serviceId) async {
  final api = context.read<BarberstuffApi>();
  try {
    await api.client.post('/staff/booking/item', body: {'id_booking': booking.id, 'id_service': serviceId});
  } on ApiException catch (e) {
    if (context.mounted) AppToast.show(context, e.message, error: true);
    return;
  }
  if (!context.mounted) return;
  await context.read<BookingsController>().refresh();
  if (context.mounted) AppToast.show(context, 'Layanan ditambahkan ke booking');
}
