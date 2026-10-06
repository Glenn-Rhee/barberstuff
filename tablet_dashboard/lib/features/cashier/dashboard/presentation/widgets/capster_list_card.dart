import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/pages/attendance_screen.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// "Karyawan Bertugas": capster toko dengan status absen hari ini
// (nonaktif di server = tidak hadir). Urutan: hadir, belum absen, tidak hadir
class CapsterListCard extends StatelessWidget {
  const CapsterListCard({super.key});

  static const _maxShown = 6;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final attendance = context.watch<AttendanceController>();
    final capsters = catalog.capsters;
    final summary = attendance.summaryOf(capsters);

    int rank(Capster c) => switch (attendance.statusOf(c)) {
      AttendanceStatus.present => 0,
      null => 1,
      AttendanceStatus.absent => 2,
    };
    final sorted = [...capsters]..sort((a, b) => rank(a).compareTo(rank(b)));

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Karyawan Bertugas', style: AppTextStyle.title),
              ),
              Text(
                '${summary.present} Hadir',
                style: AppTextStyle.label.copyWith(color: AppColor.success),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (catalog.loadingCapsters && capsters.isEmpty)
            const SkeletonTiles(count: 4)
          else if (catalog.capsterError != null)
            ErrorBar(
              message: catalog.capsterError!,
              onRetry: catalog.loadCapsters,
            )
          else if (capsters.isEmpty)
            Text(
              'Belum ada capster di toko ini.',
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            )
          else
            for (final capster in sorted.take(_maxShown))
              _CapsterTile(
                capster: capster,
                status: attendance.statusOf(capster),
                entry: attendance.entryOf(capster.id),
              ),
          if (capsters.isNotEmpty)
            TextButton.icon(
              onPressed: () => openAttendance(context),
              icon: const AppIcon(AppAsset.personIcon, size: 18),
              label: Text(
                summary.pending > 0
                    ? 'Absen ${summary.pending} capster lagi'
                    : 'Kelola Absensi',
              ),
            ),
        ],
      ),
    );
  }
}

class _CapsterTile extends StatelessWidget {
  const _CapsterTile({
    required this.capster,
    required this.status,
    required this.entry,
  });

  final Capster capster;
  final AttendanceStatus? status;
  final AttendanceEntry? entry;

  @override
  Widget build(BuildContext context) {
    final entry = this.entry;
    final (label, color) = switch (status) {
      AttendanceStatus.present when entry != null => (
        'Hadir · ${DateFormatId.time(entry.at)}',
        AppColor.success,
      ),
      AttendanceStatus.present => ('Hadir', AppColor.success),
      AttendanceStatus.absent => ('Tidak hadir', AppColor.danger),
      null => ('Belum absen', AppColor.inkSoft),
    };

    return Opacity(
      opacity: status == AttendanceStatus.absent ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            PersonAvatar(name: capster.name, photo: capster.photoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capster.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyBold,
                  ),
                  Text(
                    label,
                    style: AppTextStyle.caption.copyWith(color: color),
                  ),
                ],
              ),
            ),
            if (capster.rating > 0) ...[
              const AppIcon(AppAsset.starIcon, size: 14, tint: false),
              const SizedBox(width: 4),
              Text(
                capster.rating.toStringAsFixed(1),
                style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
