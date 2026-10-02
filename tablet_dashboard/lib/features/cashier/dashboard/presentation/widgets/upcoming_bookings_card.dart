import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/booking_status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tabel 5 booking terdekat yang belum selesai
class UpcomingBookingsCard extends StatelessWidget {
  const UpcomingBookingsCard({super.key});

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
                    const Text('Booking Berikutnya', style: AppTextStyle.title),
                    Text(
                      'Pelanggan yang belum selesai dilayani.',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.read<NavigationController>().openOrder(
                  OrderTab.reservation,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lihat Semua'),
                    Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: cells([
              for (final label in const [
                'WAKTU',
                'PELANGGAN',
                'LAYANAN',
                'CAPSTER',
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
          if (bookings.loading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (bookings.error != null)
            ErrorBar(message: bookings.error!, onRetry: bookings.refresh)
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
                  booking.scheduledAt == null
                      ? '-'
                      : DateFormatId.time(booking.scheduledAt!),
                  style: AppTextStyle.bodyBold,
                ),
                Text(
                  booking.customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyBold,
                ),
                Text(
                  booking.services.map((s) => s.item.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body,
                ),
                Text(
                  booking.capster.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
                ),
                BookingStatusBadge(status: booking.status),
              ]),
            ),
        ],
      ),
    );
  }
}
