import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              AppAssets.emptyNotify,
              width: 130,
              height: 130,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(height: 34),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 12.5,
                color: AppColor.inkFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
