import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/permission_prompt.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
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
          child: _SearchBar(
            controller: p.searchController,
            hint: l10n.bookingSearchHint,
            onSubmit: p.loadStores,
            onRefresh: () => _refresh(context, p),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onSubmit,
    required this.onRefresh,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;
  final VoidCallback onRefresh;

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (String _) => onSubmit(),
            textInputAction: TextInputAction.search,
            style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
            cursorColor: AppColor.goldDeep,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: AppTextStyle.bodySmall.copyWith(
                fontSize: 13,
                color: AppColor.inkFaint,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: _border(AppColor.border),
              enabledBorder: _border(AppColor.border),
              focusedBorder: _border(AppColor.goldDeep),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppColor.goldDeep,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onSubmit,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                AppAssets.searchBookingIcon,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
                color: AppColor.surface,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppColor.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColor.goldDeep),
          ),
          child: InkWell(
            onTap: onRefresh,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColor.goldDeep,
              ),
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
            child: BookingRadioDot(selected: selected),
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
                    if (distanceKm != null)
                      Text(
                        l10n.homeNearbyDistance(
                          distanceKm! < 10
                              ? distanceKm!.toStringAsFixed(1)
                              : distanceKm!.round().toString(),
                        ),
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColor.inkSoft,
                        ),
                      )
                    else ...<Widget>[
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
                      onTap: () => showComingSoonDialog(context),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        l10n.bookingViewStore,
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColor.goldDeep,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColor.goldDeep,
                        ),
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

class _LiteBadge extends StatelessWidget {
  const _LiteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.ink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'LITE',
        style: AppTextStyle.labelSmall.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColor.surface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
