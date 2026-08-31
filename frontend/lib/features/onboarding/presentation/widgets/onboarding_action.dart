import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_duration.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class OnboardingAction extends StatelessWidget {
  const OnboardingAction({
    super.key,
    required this.isExpanded,
    required this.label,
    required this.onPressed,
  });

  static const double _height = 52;

  final bool isExpanded;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: AnimatedContainer(
            duration: AppDuration.actionMorph,
            curve: Curves.easeOutCubic,
            width: isExpanded ? constraints.maxWidth : _height,
            height: _height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColor.orangeLight,
              borderRadius: BorderRadius.circular(_height / 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColor.orangeLight.withValues(alpha: 0.32),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AppDuration.indicatorChange,
                    child: isExpanded
                        ? Text(
                            label,
                            key: const ValueKey<String>('label'),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.clip,
                            style: AppTextStyle.labelLarge.copyWith(
                              color: AppColor.surface,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            key: ValueKey<String>('icon'),
                            color: AppColor.surface,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
