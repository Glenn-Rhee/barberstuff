import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/widgets/service_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Satu layanan di keranjang (tanpa jumlah, tiap layanan cuma 1x).
// Tombol hapus muncul kalau [onRemove] diisi
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.subtitle,
    this.onRemove,
  });

  final ServiceItem item;
  final String subtitle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final onRemove = this.onRemove;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.borderStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppIcon(ServiceIcon.of(item), size: 16, color: AppColor.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyBold.copyWith(fontSize: 12),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(PriceFormat.full(item.price), style: AppTextStyle.label),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 30,
              child: IconButton(
                tooltip: 'Hapus',
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: AppColor.danger.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                icon: const AppIcon(
                  AppAsset.trashIcon,
                  size: 14,
                  color: AppColor.danger,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
