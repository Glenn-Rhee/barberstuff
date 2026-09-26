import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_text_style.dart';
import '../../features/reservation/domain/booking.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color, required this.background});

  factory StatusBadge.booking(BookingStatus status) {
    final (color, background) = switch (status) {
      BookingStatus.booked => (AppColor.info, AppColor.infoSoft),
      BookingStatus.progress => (AppColor.purple, AppColor.purpleSoft),
      BookingStatus.completed => (AppColor.success, AppColor.successSoft),
      BookingStatus.canceled => (AppColor.danger, AppColor.dangerSoft),
    };
    return StatusBadge(label: status.label, color: color, background: background);
  }

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTextStyle.overline.copyWith(color: color, letterSpacing: 0)),
    );
  }
}
