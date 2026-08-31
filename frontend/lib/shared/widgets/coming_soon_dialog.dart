import 'package:flutter/material.dart';
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
            Icon(Icons.hourglass_top_rounded, color: AppColor.orange, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l10n.comingSoonTitle, style: AppTextStyle.titleLarge),
            ),
          ],
        ),
        content: Text(l10n.comingSoonMessage, style: AppTextStyle.bodyMedium),

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
