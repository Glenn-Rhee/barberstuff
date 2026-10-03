import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class PointsTag extends StatelessWidget {
  const PointsTag({
    super.key,
    required this.label,
    this.fontSize = 13,
    this.iconSize = 16,
  });

  final String label;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          AppAssets.pointPromo,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyle.titleSmall.copyWith(
            fontSize: fontSize,
            color: AppColor.orangeLight,
          ),
        ),
      ],
    );
  }
}
