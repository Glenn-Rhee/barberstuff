import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/features/cashier/attendance/domain/entities/attendance_entry.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';

// Badge Hadir / Tidak Hadir / Belum Absen
class AttendanceBadge extends StatelessWidget {
  const AttendanceBadge({super.key, required this.entry});

  final AttendanceEntry? entry;

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (entry?.status) {
      AttendanceStatus.present => (
        'Hadir',
        AppColor.success,
        AppColor.successSoft,
      ),
      AttendanceStatus.absent => (
        'Tidak Hadir',
        AppColor.danger,
        AppColor.dangerSoft,
      ),
      null => ('Belum Absen', AppColor.inkSoft, AppColor.surfaceMuted),
    };
    return StatusBadge(label: label, color: color, background: background);
  }
}
