import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';

// Status booking berupa badge berwarna (tabel Dashboard dan Reservasi)
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      BookingStatus.booked => (AppColor.info, AppColor.infoSoft),
      BookingStatus.progress => (AppColor.purple, AppColor.purpleSoft),
      BookingStatus.completed => (AppColor.success, AppColor.successSoft),
      BookingStatus.canceled => (AppColor.danger, AppColor.dangerSoft),
    };
    return StatusBadge(
      label: status.label,
      color: color,
      background: background,
    );
  }
}

// Status booking berupa teks biasa (judul panel booking)
class BookingStatusText extends StatelessWidget {
  const BookingStatusText({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) => Text(
    status.label,
    style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
  );
}
