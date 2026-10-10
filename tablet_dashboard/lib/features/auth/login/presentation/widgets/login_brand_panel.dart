import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Panel hitam di kiri layar login dengan logo Barberstuff
class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

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
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Transform.scale(
                    scale: 1,
                    child: Image.asset(AppAsset.logoGlyph, color: AppColor.ink),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'DASHBOARD BARBERSTUFF',
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
            SizedBox(
              width: 450,
              child: Text(
                'Dashboard yang digunakan untuk Kasir Barberstuff, Administrator, dan Mitra Barberstuff',
                style: AppTextStyle.body.copyWith(
                  color: AppColor.surface,
                  fontSize: 15,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
