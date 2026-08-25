import 'package:flutter/material.dart';

import '../../../../src/core/constants/app_duration.dart';
import '../../../../theme/app_color.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.length,
    required this.activeIndex,
  });

  final int length;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (int index) {
        final bool isActive = index == activeIndex;

        return AnimatedContainer(
          duration: AppDuration.indicatorChange,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 9 : 7,
          height: isActive ? 9 : 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColor.gold : AppColor.dotIdle,
          ),
        );
      }),
    );
  }
}
