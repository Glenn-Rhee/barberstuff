import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Satu menu sidebar, saat diperkecil cuma ikon (+ tooltip)
class SidebarNavItem extends StatelessWidget {
  const SidebarNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.expanded,
    required this.onTap,
    this.labelFontSize,
  });

  final String label;
  // Path asset ikon
  final String icon;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;
  // null = ukuran default (body)
  final double? labelFontSize;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColor.ink : AppColor.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: expanded ? '' : label,
        child: Material(
          color: selected ? AppColor.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 0),
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  AppIcon(icon, size: 20, color: foreground),
                  if (expanded) ...[
                    const SizedBox(width: 12),
<<<<<<<< HEAD:tablet_dashboard/lib/features/home/presentation/widgets/sidebar_nav_item.dart
                    // Label panjang ("Mengelola Cabang") mengecil sedikit,
                    // tidak terpotong
========
                    // Label panjang mengecil, tidak terpotong
>>>>>>>> 7d13d7e32679190728e118598f013051b3289112:tablet_dashboard/lib/features/home/shell/presentation/widgets/sidebar_nav_item.dart
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: AppTextStyle.body.copyWith(
                            color: foreground,
<<<<<<<< HEAD:tablet_dashboard/lib/features/home/presentation/widgets/sidebar_nav_item.dart
========
                            fontSize: labelFontSize,
>>>>>>>> 7d13d7e32679190728e118598f013051b3289112:tablet_dashboard/lib/features/home/shell/presentation/widgets/sidebar_nav_item.dart
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
