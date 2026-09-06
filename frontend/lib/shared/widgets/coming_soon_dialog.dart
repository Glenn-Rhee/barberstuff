import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

Future<void> showComingSoonDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppColor.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

        title: Row(
          children: <Widget>[
            Expanded(
              child: Image.asset(
                AppAssets.toolsMaintenance,
                width: 50,
                height: 50,
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.comingSoonMessage,
          style: AppTextStyle.headlineLarge.copyWith(),
          textAlign: TextAlign.center,
        ),

        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.commonUnderstood,
              style: AppTextStyle.labelLarge.copyWith(
                color: AppColor.orangeLight,
              ),
            ),
          ),
        ],
      );
    },
  );
}
