import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({
    super.key,
    required this.points,
    required this.tier,
    required this.onTap,
  });

  static const double _radius = 20;
  static const double _badge = 52;

  final int points;
  final MemberTier tier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final NumberFormat format = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Material(
      color: AppColor.ink,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColor.goldDeep.withValues(alpha: 0.14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
          child: Row(
            children: <Widget>[
              Image.asset(
                AppAssets.symbolStarDashboard,
                width: _badge,
                height: _badge,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tierLabel(tier, l10n),
                        maxLines: 1,
                        style: AppTextStyle.titleMedium.copyWith(
                          color: AppColor.goldDeep,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.homeMembershipLevel,
                        maxLines: 1,
                        style: AppTextStyle.labelMedium.copyWith(
                          color: AppColor.surface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: AppColor.surface.withValues(alpha: 0.4),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.homePoints(format.format(points)),
                        maxLines: 1,
                        style: AppTextStyle.titleMedium.copyWith(
                          color: AppColor.surface,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            l10n.homeRedeemPoints,
                            maxLines: 1,
                            style: AppTextStyle.bodySmall.copyWith(
                              color: AppColor.surface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            AppAssets.arrowFilledDashboard,
                            width: 6,
                            height: 12,
                            fit: BoxFit.contain,
                            color: AppColor.inkFaint,
                            filterQuality: FilterQuality.medium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
