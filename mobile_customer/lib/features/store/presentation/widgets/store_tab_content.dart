import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/store_detail_parts.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/store_map_preview.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class StoreAboutTab extends StatelessWidget {
  const StoreAboutTab({
    super.key,
    required this.detail,
    required this.onOpenMap,
  });

  final StoreDetail detail;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime? open = detail.openHour;
    final DateTime? close = detail.closeHour;

    final String hours = open == null || close == null
        ? '-'
        : '${DateFormat('HH.mm').format(open)} - '
              '${DateFormat('HH.mm').format(close)} WIB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionTitle(title: l10n.storeDescription),
        const SizedBox(height: 8),
        Text(
          detail.description.isEmpty ? '-' : detail.description,
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 12.5,
            height: 1.6,
            color: AppColor.inkSoft,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Divider(height: 1, thickness: 1, color: AppColor.border),
        ),
        SectionTitle(title: l10n.storeHours),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.storeHoursEveryday,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: AppColor.inkSoft,
                ),
              ),
            ),
            Text(
              hours,
              style: AppTextStyle.titleSmall.copyWith(fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionTitle(
          title: l10n.storeAddressTitle,
          actionLabel: l10n.storeSeeMap,
          onAction: onOpenMap,
        ),
        const SizedBox(height: 8),
        Text(
          detail.address,
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 12,
            color: AppColor.inkFaint,
          ),
        ),
        const SizedBox(height: 12),
        _MapCard(detail: detail, onTap: onOpenMap),
      ],
    );
  }
}

/// Peta asli kalau koordinat tersedia; kalau tidak, jatuh ke tombol polos.
class _MapCard extends StatelessWidget {
  const _MapCard({required this.detail, required this.onTap});

  final StoreDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StoreCoordinate? at = detail.coordinate;

    if (at != null) {
      return StoreMapPreview(
        storeLatitude: at.latitude,
        storeLongitude: at.longitude,
        userPosition: context.read<LocationService>().lastKnown,
        onTap: onTap,
      );
    }

    return Material(
      color: AppColor.border.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 130,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                AppAssets.routeDetailStore,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                color: AppColor.goldDeep,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.storeSeeMap,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColor.goldDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreProductTab extends StatelessWidget {
  const StoreProductTab({
    super.key,
    required this.title,
    required this.items,
    required this.emptyMessage,
    required this.isPackage,
    required this.onBook,
  });

  final String title;
  final List<ServiceItem> items;
  final String emptyMessage;
  final bool isPackage;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionTitle(
          title: title,
          actionLabel: l10n.storeSeeAll,
          onAction: () {},
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                emptyMessage,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.inkFaint,
                ),
              ),
            ),
          )
        else
          for (final ServiceItem item in items) ...<Widget>[
            _ProductCard(item: item, isPackage: isPackage, onBook: onBook),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.isPackage,
    required this.onBook,
  });

  final ServiceItem item;
  final bool isPackage;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? description = item.description;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          if (isPackage) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 54,
                height: 54,
                color: AppColor.border.withValues(alpha: 0.5),
                child: Image.asset(
                  AppAssets.promoScissors,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  description == null || description.isEmpty
                      ? l10n.storeTypeCount(1)
                      : description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColor.inkFaint,
                  ),
                ),
                if (isPackage) ...<Widget>[
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          formatRupiah(item.price),
                          style: AppTextStyle.titleSmall.copyWith(
                            fontSize: 13,
                            color: AppColor.goldDeep,
                          ),
                        ),
                      ),
                      _BookButton(label: l10n.storeBookNow, onTap: onBook),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isPackage) ...<Widget>[
            const SizedBox(width: 10),
            Text(
              formatRupiah(item.price),
              style: AppTextStyle.titleSmall.copyWith(
                fontSize: 13,
                color: AppColor.goldDeep,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookButton extends StatelessWidget {
  const _BookButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.goldDeep,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyle.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColor.surface,
            ),
          ),
        ),
      ),
    );
  }
}

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
