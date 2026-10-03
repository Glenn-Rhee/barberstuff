import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Ikon, judul, dan petunjuk saat list kosong
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColor.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColor.inkFaint),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyle.bodyBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              message,
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
