import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';

class GradeBenefitTile extends StatelessWidget {
  const GradeBenefitTile({super.key, required this.benefit});

  final GradeBenefit benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.goldSoft.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(9),
            child: Image.asset(
              benefit.iconAsset,
              fit: BoxFit.contain,
              color: AppColor.orangeDark,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  benefit.title,
                  style: AppTextStyle.titleSmall.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 3),
                Text(
                  benefit.description,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 11.5,
                    height: 1.5,
                    color: AppColor.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
