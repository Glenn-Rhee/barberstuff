import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.goldSoft.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.cloud_off_rounded,
            size: 15,
            color: AppColor.goldDeep,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineCachedData,
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 11,
                color: AppColor.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
