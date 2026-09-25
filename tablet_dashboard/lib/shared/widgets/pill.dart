import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_text_style.dart';

enum PillStyle {
  /// Gold fill when selected (tabs, filters).
  solid,

  /// Soft gold when selected (payment method).
  soft,
}

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
  final IconData? icon;
  final PillStyle style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = switch ((style, selected)) {
      (PillStyle.solid, true) => (AppColor.gold, AppColor.gold, Colors.white),
      (PillStyle.soft, true) => (AppColor.goldSoft, AppColor.gold, AppColor.gold),
      (PillStyle.solid, false) => (AppColor.surface, AppColor.borderStrong, AppColor.ink),
      (PillStyle.soft, false) => (AppColor.surfaceSubtle, AppColor.borderStrong, AppColor.ink),
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
        // No Container alignment: it would stretch the pill to the full width inside a Wrap.
        // Inside Expanded the tight width still centers the content via mainAxisAlignment.
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: foreground), const SizedBox(width: 6)],
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
