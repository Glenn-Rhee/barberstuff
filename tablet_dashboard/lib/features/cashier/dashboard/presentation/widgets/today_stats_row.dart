import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Empat angka hari ini: transaksi, penjualan, reservasi, absensi
class TodayStatsRow extends StatelessWidget {
  const TodayStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftController>();
    final dashboard = context.watch<DashboardController>();
    final capsters = context.watch<CatalogController>().activeCapsters;
    final attendance = context.watch<AttendanceController>().summaryOf(
      capsters,
    );
    final session = shift.session;
    final loadingShift = shift.loading && session == null;
    final noShift = shift.enabled ? 'Shift belum dibuka' : 'Khusus akun kasir';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: AppAsset.cartIcon,
            color: AppColor.gold,
            background: AppColor.goldSoft,
            title: 'Transaksi Hari Ini',
            loading: loadingShift,
            value: session == null ? '—' : '${session.sales.length}',
            caption: session == null
                ? noShift
                : '${session.cashSales} tunai · ${session.cashlessSales} non-tunai',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: AppAsset.graphicIcon,
            color: AppColor.success,
            background: AppColor.successSoft,
            title: 'Penjualan Hari Ini',
            loading: loadingShift,
            value: session == null ? '—' : PriceFormat.full(session.income),
            caption: session == null
                ? noShift
                : 'Kas di laci ${PriceFormat.full(session.expectedCash)}',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: AppAsset.dateIcon,
            color: AppColor.info,
            background: AppColor.infoSoft,
            title: 'Reservasi Hari Ini',
            loading: dashboard.loading && dashboard.today.isEmpty,
            value: dashboard.error != null ? '—' : '${dashboard.totalToday}',
            caption: dashboard.error != null
                ? 'Gagal memuat reservasi'
                : '${dashboard.waiting} belum datang',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: AppAsset.personIcon,
            color: AppColor.warning,
            background: AppColor.warningSoft,
            title: 'Absensi Karyawan',
            loading:
                context.watch<CatalogController>().loadingCapsters &&
                capsters.isEmpty,
            value: capsters.isEmpty ? '—' : '${attendance.present} Hadir',
            caption: capsters.isEmpty
                ? 'Belum ada capster aktif'
                : [
                    '${attendance.absent} karyawan off',
                    if (attendance.pending > 0)
                      '${attendance.pending} belum absen',
                  ].join(' · '),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.value,
    required this.caption,
    this.loading = false,
  });

  // Path asset ikon
  final String icon;
  final Color color;
  final Color background;
  final String title;
  final String value;
  final String caption;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyle.caption.copyWith(color: AppColor.inkSoft);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
                if (loading)
                  const Skeleton(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        SkeletonBox(width: 96, height: 24),
                        SizedBox(height: 8),
                        SkeletonBox(width: 120, height: 10),
                      ],
                    ),
                  )
                else ...[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: AppTextStyle.h1),
                  ),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
