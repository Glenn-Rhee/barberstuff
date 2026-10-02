import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Kartu layanan dengan harga dan "+ Tambah", angka di pojok = jumlah di keranjang
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.item,
    required this.qty,
    required this.onAdd,
  });

  final ServiceItem item;
  final int qty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColor.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: item.type == ServiceType.package
                      ? Icon(
                          Icons.workspace_premium_outlined,
                          size: 20,
                          color: AppColor.ink,
                        )
                      : AppIcon(
                          AppAsset.scissorsIcon,
                          size: 20,
                          color: AppColor.ink,
                        ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyBold.copyWith(
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    PriceFormat.full(item.price),
                    style: AppTextStyle.bodyBold.copyWith(color: AppColor.gold),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: TextButton(
                    style: AppButtonStyle.softGold,
                    onPressed: onAdd,
                    child: const Text('+ Tambah', style: AppTextStyle.label),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (qty > 0)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: AppColor.gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$qty',
                style: AppTextStyle.label.copyWith(
                  color: AppColor.surface,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
