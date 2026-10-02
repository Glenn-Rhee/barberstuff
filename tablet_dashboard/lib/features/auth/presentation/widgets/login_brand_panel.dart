import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Panel hitam di kiri layar login dengan logo Barberstuff
class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  static const _points = [
    (Icons.point_of_sale_outlined, 'Pesanan langsung & dari reservasi'),
    (Icons.print_outlined, 'Struk otomatis ke printer 58mm'),
    (Icons.insights_outlined, 'Rekap kas & shift harian'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.ink,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(AppAsset.logoGlyph, color: AppColor.ink),
                ),
                const SizedBox(width: 14),
                Text(
                  'DASHBOARD',
                  style: AppTextStyle.label.copyWith(
                    color: AppColor.gold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Image.asset(
              AppAsset.logoWordmark,
              color: AppColor.surface,
              width: 300,
            ),
            const SizedBox(height: 16),
            Text(
              'Kasir, admin, dan mitra dalam satu tablet toko.',
              style: AppTextStyle.body.copyWith(
                color: AppColor.surface,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 28),
            for (final (icon, label) in _points)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColor.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyle.body.copyWith(
                          color: AppColor.sidebarMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Text(
              'Panda PRJ-R58D · kertas 58mm',
              style: AppTextStyle.caption.copyWith(
                color: AppColor.sidebarMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
