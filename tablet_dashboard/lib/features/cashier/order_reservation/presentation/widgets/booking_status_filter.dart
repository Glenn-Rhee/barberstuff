import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/provider/bookings_controller.dart';

// Dropdown "Semua Status" untuk filter tabel booking
class BookingStatusFilter extends StatelessWidget {
  const BookingStatusFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>();

    // -1 = "Semua Status", karena value null dianggap batal oleh PopupMenuButton
    return PopupMenuButton<int>(
      tooltip: 'Filter status',
      position: PopupMenuPosition.under,
      onSelected: (index) =>
          bookings.setStatus(index < 0 ? null : BookingStatus.values[index]),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: -1,
          child: Text('Semua Status', style: AppTextStyle.body),
        ),
        for (final value in BookingStatus.values)
          PopupMenuItem(
            value: value.index,
            child: Text(value.label, style: AppTextStyle.body),
          ),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bookings.status?.label ?? 'Semua Status',
              style: AppTextStyle.body,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColor.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}
