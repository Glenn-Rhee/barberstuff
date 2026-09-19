import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/permission_prompt.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_search_bar.dart';
import 'package:mobile_barberstuff/shared/widgets/offline_banner.dart';
import 'package:provider/provider.dart';

class BookingBranchStep extends StatelessWidget {
  const BookingBranchStep({super.key});

  Future<void> _refresh(BuildContext context, BookingFlowProvider p) async {
    PermissionPrompt.allowDialogsAgain();
    await PermissionPrompt.askLocation(context);
    if (!context.mounted) return;
    await p.loadStores();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: AppSearchBar(
            controller: p.searchController,
            hint: l10n.bookingSearchHint,
            onSubmit: p.loadStores,
          ),
        ),
        if (p.storesFromCache)
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: OfflineBanner(),
          ),
        Expanded(
          child: BookingStepState(
            loading: p.loadingStores,
            error: p.storesError,
            isEmpty: p.stores.isEmpty,
            emptyMessage: l10n.bookingStoreEmpty,
            onRetry: () => _refresh(context, p),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              itemCount: p.stores.length,
              separatorBuilder: (BuildContext _, int _) =>
                  const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final StoreSummary store = p.stores[index];
                return _StoreCard(
                  store: store,
                  distanceKm: p.distanceOf(store),
                  selected: p.store?.id == store.id,
                  onTap: () => p.selectStore(store),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.distanceKm,
    required this.selected,
    required this.onTap,
  });

  final StoreSummary store;
  final double? distanceKm;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BookingSelectCard(
      selected: selected,
      enabled: store.isOpen,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: BookingRadioDot(selected: selected, check: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        store.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
                      ),
                    ),
                    if (store.isLite) ...<Widget>[
                      const SizedBox(width: 8),
                      const _LiteBadge(),
                    ],
                    const SizedBox(width: 8),
                    _StoreMetric(store: store, distanceKm: distanceKm),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        store.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColor.inkFaint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoute.storeDetail,
                        arguments: StoreDetailArgs(storeId: store.id),
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            l10n.bookingViewStore,
                            style: AppTextStyle.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColor.goldDeep,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.goldDeep,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Image.asset(
                            AppAssets.arrowLongIcon,
                            width: 12,
                            height: 10,
                            fit: BoxFit.contain,
                            color: AppColor.goldDeep,
                            filterQuality: FilterQuality.medium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Jarak kalau lokasi tersedia, kalau tidak jatuh ke rating.
class _StoreMetric extends StatelessWidget {
  const _StoreMetric({required this.store, required this.distanceKm});

  final StoreSummary store;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final double? km = distanceKm;

    if (km == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            AppAssets.starDashboard,
            width: 12,
            height: 12,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 4),
          Text(
            store.avgRating.toStringAsFixed(1),
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 11,
              color: AppColor.inkSoft,
            ),
          ),
        ],
      );
    }

    return Text(
      AppLocalizations.of(context).homeNearbyDistance(
        km < 10 ? km.toStringAsFixed(1) : km.round().toString(),
      ),
      style: AppTextStyle.bodySmall.copyWith(
        fontSize: 11.5,
        color: AppColor.inkSoft,
      ),
    );
  }
}

class _LiteBadge extends StatelessWidget {
  const _LiteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.goldSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'LITE',
        style: AppTextStyle.labelSmall.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColor.orangeDark,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
