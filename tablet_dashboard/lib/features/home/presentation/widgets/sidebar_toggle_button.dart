import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Tombol tutup/buka sidebar. Terbuka = ikon + "Tutup Menu" bergaris bawah,
// tertutup = ikon saja diputar balik (panah ke kanan)
class SidebarToggleButton extends StatelessWidget {
  const SidebarToggleButton({
    super.key,
    required this.expanded,
    required this.onTap,
  });

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = RotatedBox(
      quarterTurns: expanded ? 0 : 2,
      child: const AppIcon(
        AppAsset.closeSidebarIcon,
        size: 20,
        color: AppColor.surface,
      ),
    );

    return Tooltip(
      message: expanded ? '' : 'Buka menu',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: expanded
            ? Container(
                padding: const EdgeInsets.only(top: 6, bottom: 6),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColor.surface)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: 8),
                    Text(
                      'Tutup Menu',
                      style: AppTextStyle.body.copyWith(
                        color: AppColor.surface,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(padding: const EdgeInsets.all(6), child: icon),
      ),
    );
  }
}
