import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class BirthdayPromoCard extends StatelessWidget {
  const BirthdayPromoCard({
    super.key,
    required this.discountPercent,
    required this.onBooking,
  });

  static const double _radius = 24;

  final int discountPercent;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: ColoredBox(
        color: AppColor.goldMid,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: -26,
              top: -24,
              child: Image.asset(
                AppAssets.ellipseCard,
                width: 170,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Positioned(
              right: -48,
              bottom: -70,
              child: Image.asset(
                AppAssets.ellipseCardSecond,
                width: 216,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _Badge(label: l10n.homeBirthdayBadge),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              l10n.homeBirthdayTitle,
                              style: AppTextStyle.headlineMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.homeBirthdayDescription,
                              style: AppTextStyle.bodyMedium.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 104),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$discountPercent%',
                            maxLines: 1,
                            style: AppTextStyle.displaySmall.copyWith(
                              fontSize: 46,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _BookingButton(label: l10n.homeBookingNow, onTap: onBooking),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColor.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BookingButton extends StatelessWidget {
  const _BookingButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.ink,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColor.surface.withValues(alpha: 0.16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmall.copyWith(
                    color: AppColor.surface,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                AppAssets.arrowRightBooking,
                width: 7,
                height: 14,
                fit: BoxFit.contain,
                color: AppColor.surface,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
