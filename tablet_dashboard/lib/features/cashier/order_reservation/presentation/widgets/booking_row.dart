import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/name_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/order/domain/entities/receipt.dart';
<<<<<<< HEAD:tablet_dashboard/lib/features/cashier/reservation/presentation/widgets/booking_row.dart
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/booking_status_badge.dart';
=======
import 'package:tablet_dashboard/features/cashier/order_reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/widgets/booking_status_badge.dart';
>>>>>>> 7d13d7e32679190728e118598f013051b3289112:tablet_dashboard/lib/features/cashier/order_reservation/presentation/widgets/booking_row.dart

// Satu baris di tabel reservasi, tap untuk buka detail pelanggan
class BookingRow extends StatelessWidget {
  const BookingRow({
    super.key,
    required this.booking,
    required this.selected,
    required this.onTap,
  });

  final Booking booking;
  final bool selected;
  final VoidCallback onTap;

  static const _flex = [7, 3, 5, 4, 4];

  // Susunan lima kolom, dipakai juga oleh header tabel
  static Widget cells(
    List<Widget> children, {
    Widget trailing = const SizedBox(width: 24),
  }) => Row(
    children: [
      for (final (i, child) in children.indexed)
        Expanded(
          flex: _flex[i],
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      trailing,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final main = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: cells(
        [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: selected
                    ? AppColor.goldBorder
                    : AppColor.surfaceMuted,
                child: Text(
                  initialsOf(booking.customer.name),
                  style: AppTextStyle.label.copyWith(
                    fontSize: 10,
                    color: AppColor.inkSoft,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodyBold.copyWith(fontSize: 12),
                    ),
                    Text(
                      Receipt.numberFor(booking.id),
                      style: AppTextStyle.caption.copyWith(
                        fontSize: 10,
                        color: AppColor.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            booking.scheduledAt == null
                ? '-'
                : DateFormatId.time(booking.scheduledAt!),
            style: AppTextStyle.bodyBold.copyWith(fontSize: 13),
          ),
          Text(
            booking.services.map((s) => s.item.name).join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body.copyWith(fontSize: 12),
          ),
          Text(
            booking.capster.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body.copyWith(fontSize: 12),
          ),
          BookingStatusBadge(status: booking.status),
        ],
        trailing: SizedBox(
          width: 24,
          child: Icon(
            selected ? Icons.keyboard_arrow_up : Icons.chevron_right,
            color: AppColor.inkSoft,
            size: 20,
          ),
        ),
      ),
    );

    if (!selected) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColor.border)),
          ),
          child: main,
        ),
      );
    }

    final customer = booking.customer;
    Widget detail(String label, String value, {Color? color}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.label.copyWith(
              fontSize: 9,
              color: AppColor.inkSoft,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.label.copyWith(color: color),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.goldSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.goldBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: main,
          ),
          const Divider(color: AppColor.goldBorder, indent: 12, endIndent: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                detail('TELEPON', customer.phone ?? '-'),
                detail(
                  'MEMBERSHIP',
                  customer.membershipLabel,
                  color: customer.isMember ? AppColor.gold : AppColor.inkSoft,
                ),
                detail(
                  'POIN PELANGGAN',
                  '${PriceFormat.plain(customer.memberPoints)} poin',
                ),
                detail('LAYANAN FAVORIT', customer.favoriteService ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
