import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
    this.messageStyle,
    this.actionStyle,
    this.gap = 4,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;
  final TextStyle? messageStyle;
  final TextStyle? actionStyle;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                messageStyle ??
                AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
          ),
        ),
        SizedBox(width: gap),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            splashColor: AppColor.orangeLight.withValues(alpha: 0.14),
            highlightColor: AppColor.orangeLight.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Text(
                actionLabel,
                maxLines: 1,
                style:
                    actionStyle ??
                    AppTextStyle.bodyMedium.copyWith(
                      color: AppColor.orangeLight,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
