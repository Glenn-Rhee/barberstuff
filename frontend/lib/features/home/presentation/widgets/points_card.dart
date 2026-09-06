import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/theme/tier_theme.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/tier_label.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({
    super.key,
    required this.points,
    required this.pointsToNextTier,
    required this.progress,
    required this.tier,
    required this.onTap,
  });

  static const double _radius = 20;
  static const double _badge = 36;
  static const double _star = 24;

  final int points;

  final int pointsToNextTier;

  final double progress;

  final MemberTier tier;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final NumberFormat format = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Material(
      color: AppColor.orangeDashboard,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: _badge,
                    height: _badge,
                    decoration: const BoxDecoration(
                      color: AppColor.ink,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppAssets.symbolStarDashboard,
                        width: _star,
                        height: _star,
                        fit: BoxFit.contain,
                        color: AppColor.surface,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.homePoints(format.format(points)),
                        maxLines: 1,
                        style: AppTextStyle.headlineSmall,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: _TierPill(tier: tier)),
                ],
              ),
              if (pointsToNextTier > 0) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  l10n.homePointsToPremium(format.format(pointsToNextTier)),
                  style: AppTextStyle.labelSmall,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 9,
                        backgroundColor: AppColor.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColor.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Image.asset(
                    AppAssets.arrowFilledDashboard,
                    width: 11,
                    height: 22,
                    fit: BoxFit.contain,
                    color: AppColor.ink,
                    filterQuality: FilterQuality.medium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierPill extends StatelessWidget {
  const _TierPill({required this.tier});

  final MemberTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColor.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tierLabel(tier, AppLocalizations.of(context)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.bodySmall.copyWith(
          color: TierTheme.of(tier).accent,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
