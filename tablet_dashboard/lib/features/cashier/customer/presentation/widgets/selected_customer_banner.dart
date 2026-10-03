import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';

// Bar pelanggan terpilih di atas katalog: nama, status, poin, no HP
class SelectedCustomerBanner extends StatelessWidget {
  const SelectedCustomerBanner({
    super.key,
    required this.customer,
    required this.onClear,
  });

  final CustomerProfile customer;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final details = [
      customer.statusLabel,
      if (customer.isMember) '${PriceFormat.plain(customer.points)} poin',
      ?customer.phone,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColor.goldSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.goldBorder),
      ),
      child: Row(
        children: [
          PersonAvatar(name: customer.name, photo: customer.photoUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: AppTextStyle.bodyBold),
                Text(
                  details.join(' • '),
                  style: AppTextStyle.caption.copyWith(
                    color: customer.isMember ? AppColor.gold : AppColor.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ganti pelanggan',
            onPressed: onClear,
            icon: const Icon(Icons.cancel, color: AppColor.danger, size: 20),
          ),
        ],
      ),
    );
  }
}
