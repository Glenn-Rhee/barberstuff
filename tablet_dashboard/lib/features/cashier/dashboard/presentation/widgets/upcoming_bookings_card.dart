import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/widgets/arrival_badge.dart';
<<<<<<< HEAD
import 'package:tablet_dashboard/features/home/presentation/provider/navigation_controller.dart';
=======
import 'package:tablet_dashboard/features/home/shell/presentation/provider/navigation_controller.dart';
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tabel "Reservasi Berikutnya": 5 booking hari ini yang belum selesai
class UpcomingBookingsCard extends StatelessWidget {
  const UpcomingBookingsCard({super.key});

  static const _flex = [2, 4, 4, 3, 4];

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController>();
    final upcoming = dashboard.upcoming.take(5).toList();
    final now = DateTime.now();

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
                    const Text(
                      'Reservasi Berikutnya',
                      style: AppTextStyle.title,
                    ),
                    Text(
                      'Pelanggan yang akan datang hari ini.',
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
                    AppIcon(AppAsset.rightArrowIcon, size: 12),
                  ],
                ),
              ),
            ],
          ),
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
          if (dashboard.loading && upcoming.isEmpty)
            const SkeletonRows(flex: _flex, count: 4, rowHeight: 48)
          else if (dashboard.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ErrorBar(
                message: dashboard.error!,
                onRetry: dashboard.refresh,
              ),
            )
          else if (upcoming.isEmpty)
            const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Belum ada reservasi',
              message: 'Reservasi hari ini akan tampil di sini.',
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
                ArrivalBadge(booking: booking, now: now),
              ]),
            ),
        ],
      ),
    );
  }
}
