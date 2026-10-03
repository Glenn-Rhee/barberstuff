import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/promo/domain/entities/promo_content.dart';

class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    // Ikut melebar saat skala teks dinaikkan supaya teks tidak terpotong.
    final double scale = MediaQuery.textScalerOf(context).scale(1);

    return Container(
      width: 170 * scale,
      padding: const EdgeInsets.all(14),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: banner.highlighted ? Colors.transparent : AppColor.border,
        ),
        gradient: banner.highlighted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColor.orangeDashboard, AppColor.goldSoft],
              )
            : null,
        color: banner.highlighted ? null : AppColor.surface,
      ),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                banner.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.titleMedium.copyWith(
                  fontSize: 17,
                  color: AppColor.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                banner.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColor.ink,
                ),
              ),
              const Spacer(),
              Text(
                banner.footnote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: banner.highlighted
                      ? FontWeight.w400
                      : FontWeight.w700,
                  color: banner.highlighted
                      ? AppColor.inkSoft
                      : AppColor.orangeLight,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                banner.iconAsset,
                width: 26,
                height: 26,
                fit: BoxFit.contain,
                color: AppColor.ink,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
