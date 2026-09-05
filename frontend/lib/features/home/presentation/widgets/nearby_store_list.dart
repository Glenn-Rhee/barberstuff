import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/home/domain/dashboard_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class NearbyStoreList extends StatelessWidget {
  const NearbyStoreList({
    super.key,
    required this.stores,
    required this.onSelect,
    required this.horizontalPadding,
  });

  static const double _cardWidth = 190;
  static const double _height = 200;

  final List<NearbyStore> stores;
  final void Function(NearbyStore store) onSelect;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: stores.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final NearbyStore store = stores[index];
          return SizedBox(
            width: _cardWidth,
            child: _StoreCard(store: store, onTap: () => onSelect(store)),
          );
        },
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.onTap});

  final NearbyStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NumberFormat decimal = NumberFormat('0.0', 'en');

    return Material(
      color: AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 11,
              child: Image.asset(
                store.imageAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    const ColoredBox(color: AppColor.border),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        AppAssets.starDashboard,
                        width: 13,
                        height: 13,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        decimal.format(store.rating),
                        style: AppTextStyle.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.homeNearbyDistance(
                          decimal.format(store.distanceKm),
                        ),
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColor.inkFaint,
                        ),
                      ),
                    ],
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
