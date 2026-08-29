import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
    this.tooltip,
    this.size = 52,
  });

  final String iconPath;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: AppColor.surface,
        clipBehavior: Clip.antiAlias,
        shape: const CircleBorder(side: BorderSide(color: AppColor.border)),
        child: InkWell(
          onTap: onPressed,
          splashColor: AppColor.orangeLight.withValues(alpha: 0.12),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
          ),
        ),
      ),
    );
  }
}
