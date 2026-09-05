import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class BenefitCard extends StatelessWidget {
  const BenefitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final List<String> benefits = <String>[
      l10n.homeBenefitPoints,
      l10n.homeBenefitBirthday,
      l10n.homeBenefitPriority,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < benefits.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  AppAssets.checkYelllowDashboard,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(benefits[i], style: AppTextStyle.bodyMedium),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
