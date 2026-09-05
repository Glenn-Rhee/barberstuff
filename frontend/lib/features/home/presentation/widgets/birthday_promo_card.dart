import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class BirthdayPromoCard extends StatelessWidget {
  const BirthdayPromoCard({
    super.key,
    required this.discountPercent,
    required this.onSeePromo,
  });

  static const double _radius = 20;

  final int discountPercent;
  final VoidCallback onSeePromo;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.ink,
        borderRadius: BorderRadius.circular(_radius),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.homeBirthdayTitle,
                  style: AppTextStyle.titleMedium.copyWith(
                    color: AppColor.surface,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 230,
                  child: Text(
                    l10n.homeBirthdayDescription,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColor.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _PromoButton(label: l10n.homeSeePromo, onPressed: onSeePromo),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$discountPercent%',
                style: AppTextStyle.displaySmall.copyWith(
                  color: AppColor.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Image.asset(
                AppAssets.cakeDashboard,
                width: 76,
                height: 76,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoButton extends StatelessWidget {
  const _PromoButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.orangeLight,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: AppColor.surface.withValues(alpha: 0.18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: AppTextStyle.titleSmall.copyWith(color: AppColor.surface),
          ),
        ),
      ),
    );
  }
}
