import 'package:flutter/material.dart';

import '../../../../theme/app_color.dart';

class BrandGlow extends StatelessWidget {
  const BrandGlow({
    super.key,
    required this.animation,
    this.color = AppColor.surface,
    this.intensity = 0.22,
  });

  final Animation<double> animation;
  final Color color;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final double baseSize = MediaQuery.sizeOf(context).width;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double diameter = baseSize * animation.value;

          return SizedBox(
            width: diameter,
            height: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    color.withValues(alpha: intensity),
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
