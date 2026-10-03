import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_stores.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:mobile_barberstuff/features/store/presentation/provider/store_list_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/error_retry_view.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/skeleton.dart';
import 'package:mobile_barberstuff/shared/widgets/form/app_search_bar.dart';
import 'package:mobile_barberstuff/shared/widgets/media/store_image.dart';
import 'package:mobile_barberstuff/shared/widgets/navigation/app_back_bar.dart';
import 'package:provider/provider.dart';

class StoreListPage extends StatelessWidget {
  const StoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreListProvider>(
      create: (BuildContext ctx) =>
          StoreListProvider(ctx.read<GetStores>(), ctx.read<LocationService>()),
      child: const _StoreListView(),
    );
  }
}

class _StoreListView extends StatelessWidget {
  const _StoreListView();

  static const double _sidePadding = 20;

  void _openDetail(BuildContext context, StoreSummary store) {
    Navigator.of(context).pushNamed(
      AppRoute.storeDetail,
      arguments: StoreDetailArgs(storeId: store.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StoreListProvider p = context.watch<StoreListProvider>();

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBackBar(title: l10n.storeListTitle, useMaterialBackIcon: true),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _sidePadding,
                4,
                _sidePadding,
                14,
              ),
              child: AppSearchBar(
                controller: p.searchController,
                hint: l10n.bookingSearchHint,
              ),
            ),
            Expanded(
              child: _Body(provider: p, onSelect: _openDetail),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.provider, required this.onSelect});

  final StoreListProvider provider;
  final void Function(BuildContext context, StoreSummary store) onSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ApiException? error = provider.error;
    final List<StoreSummary> stores = provider.stores;

    if (provider.isLoading && stores.isEmpty) {
      return const SkeletonList(
        itemCount: 6,
        padding: EdgeInsets.fromLTRB(
          _StoreListView._sidePadding,
          0,
          _StoreListView._sidePadding,
          24,
        ),
      );
    }

    if (error != null && stores.isEmpty) {
      return ErrorRetryView(
        message: error.message(l10n),
        onRetry: provider.load,
      );
    }

    if (stores.isEmpty) {
      return ErrorRetryView(
        message: l10n.bookingStoreEmpty,
        onRetry: provider.load,
        showButton: false,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.load,
      color: AppColor.goldDeep,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          _StoreListView._sidePadding,
          0,
          _StoreListView._sidePadding,
          24,
        ),
        itemCount: stores.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final StoreSummary store = stores[index];
          return _StoreRow(
            store: store,
            distanceKm: provider.distanceOf(store),
            onTap: () => onSelect(context, store),
          );
        },
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.distanceKm,
    required this.onTap,
  });

  static const double _radius = 14;
  static const double _thumbSize = 74;

  final StoreSummary store;
  final double? distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NumberFormat decimal = NumberFormat('0.0', 'id');
    final double? km = distanceKm;

    return Material(
      color: AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: const BorderSide(color: AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: _thumbSize,
                  height: _thumbSize,
                  child: StoreImage(url: store.bannerUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      km == null
                          ? store.address
                          : l10n.homeNearbyLocation(
                              store.address,
                              decimal.format(km),
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColor.inkFaint,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          AppAssets.starDashboard,
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          decimal.format(store.avgRating),
                          style: AppTextStyle.bodySmall.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                AppAssets.arrowFilledDashboard,
                width: 7,
                height: 14,
                fit: BoxFit.contain,
                color: AppColor.inkSoft,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
