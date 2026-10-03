import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

enum PillStyle {
  // Emas penuh saat dipilih (tab, filter)
  solid,

  // Emas muda saat dipilih (metode bayar)
  soft,
}

// Tombol pilihan bulat untuk tab, filter, dan metode bayar
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.style = PillStyle.solid,
    this.height = 36,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  // Path asset ikon (opsional)
  final String? icon;
  final PillStyle style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = switch ((style, selected)) {
      (PillStyle.solid, true) => (
        AppColor.gold,
        AppColor.gold,
        AppColor.surface,
      ),
      (PillStyle.soft, true) => (
        AppColor.goldSoft,
        AppColor.gold,
        AppColor.gold,
      ),
      (PillStyle.solid, false) => (
        AppColor.surface,
        AppColor.borderStrong,
        AppColor.ink,
      ),
      (PillStyle.soft, false) => (
        AppColor.surfaceSubtle,
        AppColor.borderStrong,
        AppColor.ink,
      ),
    };

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        // Sengaja tanpa alignment, biar tidak melebar penuh di dalam Wrap
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                AppIcon(icon!, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.label.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
