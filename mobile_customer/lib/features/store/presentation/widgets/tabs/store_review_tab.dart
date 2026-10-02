import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/network_avatar.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/section_title.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/star_row.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class StoreReviewTab extends StatelessWidget {
  const StoreReviewTab({super.key, required this.detail});

  final StoreDetail detail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionTitle(
          title: l10n.storeReviewsTitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                AppAssets.starHistoryFilled,
                width: 13,
                height: 13,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 5),
              Text(
                '${detail.avgRating.toStringAsFixed(1)} / 5.0',
                style: AppTextStyle.titleSmall.copyWith(fontSize: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (detail.reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.storeNoReview,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.inkFaint,
                ),
              ),
            ),
          )
        else
          for (final StoreReview review in detail.reviews) ...<Widget>[
            _ReviewCard(review: review),
            const SizedBox(height: 14),
          ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final StoreReview review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            NetworkAvatar(url: review.userImageUrl, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    review.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.userTier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall.copyWith(
                      fontSize: 10.5,
                      color: AppColor.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StarRow(rating: review.rating.toDouble(), size: 12),
        const SizedBox(height: 8),
        Text(
          review.message,
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 12,
            height: 1.55,
            color: AppColor.inkSoft,
          ),
        ),
      ],
    );
  }
}
