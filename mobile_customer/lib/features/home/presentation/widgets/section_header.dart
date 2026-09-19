import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final String? label = actionLabel;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: AppTextStyle.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (label != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTextStyle.labelMedium.copyWith(
                      color: AppColor.orangeLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    AppAssets.arrowFilledDashboard,
                    width: 7,
                    height: 14,
                    fit: BoxFit.contain,
                    color: AppColor.orangeLight,
                    filterQuality: FilterQuality.medium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
