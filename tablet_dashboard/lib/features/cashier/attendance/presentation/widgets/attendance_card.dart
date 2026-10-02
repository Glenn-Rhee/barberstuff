import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/widgets/attendance_badge.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Kartu satu capster: foto, nama, status absen, tombol Hadir / Tidak Hadir
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.capster,
    required this.entry,
    required this.onMark,
  });

  final Capster capster;
  final AttendanceEntry? entry;
  final ValueChanged<AttendanceStatus> onMark;

  @override
  Widget build(BuildContext context) {
    final status = entry?.status;

    return AppCard(
      child: Column(
        children: [
          PersonAvatar(name: capster.name, photo: capster.photoUrl, size: 52),
          const SizedBox(height: 8),
          Text(
            capster.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.bodyBold,
          ),
          const SizedBox(height: 4),
          AttendanceBadge(entry: entry),
          if (entry != null)
            Text(
              'Dicatat ${DateFormatId.time(entry!.at)}',
              style: AppTextStyle.caption.copyWith(color: AppColor.inkFaint),
            ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _MarkButton(
                  label: 'Hadir',
                  color: AppColor.success,
                  selected: status == AttendanceStatus.present,
                  onTap: () => onMark(AttendanceStatus.present),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MarkButton(
                  label: 'Tidak Hadir',
                  color: AppColor.danger,
                  selected: status == AttendanceStatus.absent,
                  onTap: () => onMark(AttendanceStatus.absent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          foregroundColor: selected ? AppColor.surface : color,
          backgroundColor: selected ? color : AppColor.surface,
          side: BorderSide(color: color),
          textStyle: AppTextStyle.label,
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
  }
}
