import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/shared/widgets/animated_brand_logo.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isVisible,
    required this.message,
    required this.child,
  });

  final bool isVisible;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        if (isVisible)
          Positioned.fill(
            child: AbsorbPointer(
              child: Material(
                color: AppColor.ink.withValues(alpha: 0.92),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const AnimatedBrandLogo(
                        width: 130,
                        tint: AppColor.orangeLight,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        message,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColor.cream,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
