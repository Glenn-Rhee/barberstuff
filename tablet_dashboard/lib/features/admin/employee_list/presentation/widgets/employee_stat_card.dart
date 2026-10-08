import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Kartu angka ringkasan: ikon di lingkaran berwarna, label, angka besar
class EmployeeStatCard extends StatelessWidget {
  const EmployeeStatCard({
    super.key,
    required this.icon,
    required this.background,
    required this.label,
    required this.value,
  });

  final String icon;
  final Color background;
  final String label;

  // null = masih dimuat
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: AppIcon(icon, size: 22, tint: false),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
                Text(
                  value?.toString() ?? '-',
                  style: AppTextStyle.h2.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
