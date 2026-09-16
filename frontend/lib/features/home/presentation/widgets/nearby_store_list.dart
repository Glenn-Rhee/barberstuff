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
    required this.onBooking,
    required this.horizontalPadding,
  });

  static const double _height = 200;
  static const double _widthRatio = 0.84;

  final List<NearbyStore> stores;
  final void Function(NearbyStore store) onSelect;
  final void Function(NearbyStore store) onBooking;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.textScalerOf(context).scale(1);
    final double cardWidth =
        (MediaQuery.sizeOf(context).width - (horizontalPadding * 2)) *
        _widthRatio;

    return SizedBox(
      height: _height + (scale - 1) * 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: stores.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final NearbyStore store = stores[index];
          return SizedBox(
            width: cardWidth,
            child: _StoreCard(
              store: store,
              onTap: () => onSelect(store),
              onBooking: () => onBooking(store),
            ),
          );
        },
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.onTap,
    required this.onBooking,
  });

  static const double _radius = 16;

  final NearbyStore store;
  final VoidCallback onTap;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NumberFormat decimal = NumberFormat('0.0', 'id');

    return Material(
      color: AppColor.border,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _StoreImage(store: store),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColor.backdrop.withValues(alpha: 0),
                    AppColor.backdrop.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 14, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            store.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.headlineSmall.copyWith(
                              color: AppColor.surface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.homeNearbyLocation(
                              store.city,
                              decimal.format(store.distanceKm),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.bodySmall.copyWith(
                              color: AppColor.surface,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(
                                AppAssets.starDashboard,
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                decimal.format(store.rating),
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: AppColor.surface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _BookingPill(
                      label: l10n.homeActionBooking,
                      onTap: onBooking,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner dari server kalau ada, kalau gagal jatuh ke aset bawaan.
class _StoreImage extends StatelessWidget {
  const _StoreImage({required this.store});

  final NearbyStore store;

  @override
  Widget build(BuildContext context) {
    final String? url = store.imageUrl;

    final Widget fallback = Image.asset(
      store.imageAsset,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
          const ColoredBox(color: AppColor.border),
    );

    if (url == null) return fallback;

    return Image.network(
      url,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (BuildContext _, Object _, StackTrace? _) => fallback,
    );
  }
}

class _BookingPill extends StatelessWidget {
  const _BookingPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColor.goldDeep.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
