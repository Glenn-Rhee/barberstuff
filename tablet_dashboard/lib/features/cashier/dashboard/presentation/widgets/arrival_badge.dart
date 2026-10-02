import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';

// Status kedatangan di tabel dashboard:
// progress = Sudah Check-in, booked lewat jadwal = Menunggu, booked nanti = Dijadwalkan
class ArrivalBadge extends StatelessWidget {
  const ArrivalBadge({super.key, required this.booking, required this.now});

  final Booking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheduled = booking.scheduledAt;
    final (label, color, background) = switch (booking.status) {
      BookingStatus.progress => (
        'Sudah Check-in',
        AppColor.success,
        AppColor.successSoft,
      ),
      BookingStatus.completed => (
        'Selesai',
        AppColor.inkSoft,
        AppColor.surfaceMuted,
      ),
      BookingStatus.canceled => ('Batal', AppColor.danger, AppColor.dangerSoft),
      BookingStatus.booked when scheduled != null && !scheduled.isAfter(now) =>
        ('Menunggu', AppColor.warning, AppColor.warningSoft),
      BookingStatus.booked => ('Dijadwalkan', AppColor.info, AppColor.infoSoft),
    };
    return StatusBadge(label: label, color: color, background: background);
  }
}
