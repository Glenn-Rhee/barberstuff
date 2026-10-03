import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/widgets/service_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Kartu layanan dengan harga dan "+ Tambah". Sudah di keranjang =
// tombol jadi "Dipilih", tap lagi untuk keluarkan dari keranjang
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ServiceItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: selected ? AppColor.goldSoft : null,
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
            child: AppIcon(ServiceIcon.of(item), size: 20, color: AppColor.ink),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              children: [
                // Nama panjang mengecil jadi 1 baris kalau tempat tidak cukup
                Flexible(
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
                Text(
                  item.type.label,
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
              ],
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
            child: selected
                ? FilledButton.icon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: EdgeInsets.zero,
                      textStyle: AppTextStyle.label,
                    ),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Dipilih'),
                  )
                : TextButton(
                    style: AppButtonStyle.softGold,
                    onPressed: onTap,
                    child: const Text('+ Tambah', style: AppTextStyle.label),
                  ),
          ),
        ],
      ),
    );
  }
}
