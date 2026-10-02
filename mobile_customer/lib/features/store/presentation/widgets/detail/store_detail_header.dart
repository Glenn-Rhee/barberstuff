import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/star_row.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Foto sampul cabang di puncak halaman detail.
class StoreDetailBanner extends StatelessWidget {
  const StoreDetailBanner({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: url.isEmpty
          ? const ColoredBox(color: AppColor.border)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                  const ColoredBox(color: AppColor.border),
            ),
    );
  }
}

/// Nama cabang + status buka, alamat, lalu rating dan jumlah ulasan.
class StoreDetailInfo extends StatelessWidget {
  const StoreDetailInfo({super.key, required this.detail});

  final StoreDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TitleRow(detail: detail),
        const SizedBox(height: 8),
        _AddressRow(address: detail.address),
        const SizedBox(height: 8),
        _RatingRow(detail: detail),
      ],
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.detail});

  final StoreDetail detail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            detail.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: detail.isOpen
                ? const Color(0xFFE6F2FB)
                : AppColor.border.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            detail.isOpen ? l10n.storeOpen : l10n.storeClosed,
            style: AppTextStyle.labelSmall.copyWith(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: detail.isOpen ? const Color(0xFF3A8DC4) : AppColor.inkSoft,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Image.asset(
            AppAssets.locationIcon,
            width: 13,
            height: 13,
            fit: BoxFit.contain,
            color: AppColor.inkFaint,
            filterQuality: FilterQuality.medium,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 12,
              color: AppColor.inkFaint,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.detail});

  final StoreDetail detail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        StarRow(rating: detail.avgRating),
        const SizedBox(width: 6),
        Text(
          detail.avgRating.toStringAsFixed(1),
          style: AppTextStyle.titleSmall.copyWith(fontSize: 12.5),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.storeReviewCount(
              NumberFormat.decimalPattern(
                Localizations.localeOf(context).toLanguageTag(),
              ).format(detail.reviewCount),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 12,
              color: AppColor.inkFaint,
            ),
          ),
        ),
      ],
    );
  }
}
