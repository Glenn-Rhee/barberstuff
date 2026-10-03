import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/home/presentation/models/dashboard_content.dart';

class BenefitCarousel extends StatelessWidget {
  const BenefitCarousel({
    super.key,
    required this.benefits,
    required this.horizontalPadding,
  });

  static const double _height = 156;
  static const double _peek = 26;

  final List<BenefitItem> benefits;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.8);
    final double cardWidth =
        MediaQuery.sizeOf(context).width - (horizontalPadding * 2) - _peek;

    return SizedBox(
      height: _height * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: benefits.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: cardWidth,
            child: _BenefitCard(benefit: benefits[index]),
          );
        },
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefit});

  static const double _radius = 20;

  final BenefitItem benefit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: ColoredBox(
        color: AppColor.goldMid,
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -46,
              top: -34,
              child: Image.asset(
                AppAssets.ellipseCardSecond,
                width: 206,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          benefit.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          benefit.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    benefit.imageAsset,
                    width: 84,
                    height: 84,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
