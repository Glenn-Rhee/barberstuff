import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/order_tab_layout.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/booking_panel.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/booking_row.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/booking_status_filter.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Tab "Dari Reservasi": booking toko dari GET /booking
class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  @override
  void initState() {
    super.initState();
    // Booking baru dari aplikasi pelanggan langsung kelihatan saat tab dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bookings = context.read<BookingsController>();
      bookings.refresh(silent: bookings.bookings.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>();

    return OrderTabLayout(
      panel: const BookingPanel(),
      children: [
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
            const BookingStatusFilter(),
            const SizedBox(width: 12),
            const _DateChip(),
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
                  child: BookingRow.cells([
                    for (final label in const [
                      'PELANGGAN',
                      'JADWAL',
                      'LAYANAN',
                      'BARBER',
                      'STATUS',
                    ])
                      Text(
                        label,
                        style: AppTextStyle.label.copyWith(
                          fontSize: 11,
                          color: AppColor.inkSoft,
                        ),
                      ),
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
          page: bookings.page - 1, // halaman API mulai dari 1
          pageCount: bookings.totalPages,
          onChanged: (page) => bookings.setPage(page + 1),
        ),
      ],
    );
  }

  Widget _list(BookingsController bookings) {
    if (bookings.loading) {
      return const SkeletonRows(flex: [7, 3, 5, 4, 4], count: 5, avatar: true);
    }
    if (bookings.error != null) {
      return ErrorRetryView(
        title: 'Gagal memuat booking',
        message: bookings.error!,
        onRetry: bookings.refresh,
      );
    }
    if (bookings.bookings.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Belum ada booking',
        message: bookings.isToday
            ? 'Booking dari aplikasi pelanggan akan muncul di sini.'
            : 'Tidak ada booking pada ${DateFormatId.longDate(bookings.day)}.',
      );
    }

    return RefreshIndicator(
      onRefresh: bookings.refresh,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          for (final booking in bookings.bookings)
            BookingRow(
              booking: booking,
              selected: bookings.selectedId == booking.id,
              onTap: () => bookings.toggle(booking),
            ),
        ],
      ),
    );
  }
}

// Pilih tanggal booking, selain hari ini chip emas + tombol kembali
class _DateChip extends StatelessWidget {
  const _DateChip();

  // Batas mundur kalender, cukup untuk cari booking progress yang lupa dibayar
  static const _maxDaysBack = 365;

  Future<void> _pick(BuildContext context) async {
    final bookings = context.read<BookingsController>();
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: bookings.day,
      firstDate: today.subtract(const Duration(days: _maxDaysBack)),
      lastDate: today,
      helpText: 'Pilih tanggal booking',
    );
    if (picked != null) bookings.setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>();
    final today = bookings.isToday;

    return Material(
      color: today ? AppColor.surface : AppColor.goldSoft,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: EdgeInsets.only(left: 12, right: today ? 12 : 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: today ? AppColor.borderStrong : AppColor.goldBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(AppAsset.dateIcon, size: 16, color: AppColor.ink),
              const SizedBox(width: 8),
              // Bulan disingkat kalau ada tombol kembali, supaya muat
              Text(
                today
                    ? DateFormatId.longDate(bookings.day)
                    : DateFormatId.mediumDate(bookings.day),
                style: AppTextStyle.body,
              ),
              if (!today)
                IconButton(
                  tooltip: 'Kembali ke hari ini',
                  onPressed: () => bookings.setDate(DateTime.now()),
                  icon: const Icon(Icons.close, size: 16),
                  color: AppColor.inkSoft,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
