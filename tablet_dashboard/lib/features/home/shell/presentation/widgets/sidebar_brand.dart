import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/widgets/sidebar_toggle_button.dart';

// Logo, nama aplikasi + role, dan tombol tutup/buka sidebar
class SidebarBrand extends StatelessWidget {
  const SidebarBrand({
    super.key,
    required this.roleLabel,
    required this.expanded,
    required this.onToggle,
  });

  final String roleLabel;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 36,
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Transform.scale(
        scale: 1,
        child: Image.asset(AppAsset.logoGlyph, color: AppColor.ink),
      ),
    );
    final toggle = SidebarToggleButton(expanded: expanded, onTap: onToggle);

    if (!expanded) {
      return Column(children: [toggle, const SizedBox(height: 12), logo]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        toggle,
        const SizedBox(height: 20),
        Row(
          children: [
            logo,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BARBERSTUFF',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyBold.copyWith(
                      color: AppColor.surface,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    roleLabel.toUpperCase(),
                    style: AppTextStyle.label.copyWith(
                      color: AppColor.sidebarMuted,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
