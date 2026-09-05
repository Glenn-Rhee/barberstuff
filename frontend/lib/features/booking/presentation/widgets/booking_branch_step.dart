import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingBranchStep extends StatelessWidget {
  const BookingBranchStep({super.key, required this.onViewStore});

  final void Function(BookingStore store) onViewStore;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();
    final List<BookingStore> stores = p.stores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Text(
            l10n.bookingNearbyHeadline,
            style: AppTextStyle.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SearchField(controller: p.searchController),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: stores.isEmpty
              ? Center(
                  child: Text(
                    l10n.bookingStoreEmpty,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColor.inkFaint,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: stores.length,
                  separatorBuilder: (BuildContext _, int _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final BookingStore store = stores[index];
                    return _StoreTile(
                      store: store,
                      selected: p.storeId == store.id,
                      onTap: () => p.selectStore(store.id),
                      onViewStore: () => onViewStore(store),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyle.bodyMedium,
              cursorColor: AppColor.orange,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.bookingSearchHint,
                hintStyle: AppTextStyle.bodyMedium.copyWith(
                  color: AppColor.inkFaint,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Container(
            width: 52,
            height: 52,
            color: AppColor.orangeLight,
            child: Center(
              child: Image.asset(
                AppAssets.searchBookingIcon,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                color: AppColor.surface,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.store,
    required this.selected,
    required this.onTap,
    required this.onViewStore,
  });

  final BookingStore store;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onViewStore;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NumberFormat decimal = NumberFormat('0.0', 'en');

    return Material(
      color: selected
          ? AppColor.orangeDashboard.withValues(alpha: 0.18)
          : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColor.orangeLight : AppColor.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Radio(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            store.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.titleMedium,
                          ),
                        ),
                        if (store.isNewbie) ...<Widget>[
                          const SizedBox(width: 8),
                          const _NewbieBadge(),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          l10n.homeNearbyDistance(
                            decimal.format(store.distanceKm),
                          ),
                          style: AppTextStyle.bodySmall.copyWith(
                            color: AppColor.inkSoft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            store.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.bodySmall.copyWith(
                              color: AppColor.inkFaint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ViewStoreLink(onTap: onViewStore),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewbieBadge extends StatelessWidget {
  const _NewbieBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.orangeDashboard,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'NEWBIE',
        style: AppTextStyle.bodySmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ViewStoreLink extends StatelessWidget {
  const _ViewStoreLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.bookingViewStore,
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColor.orangeLight,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColor.orangeLight,
            ),
          ),
          const SizedBox(width: 5),
          Image.asset(
            AppAssets.arrowRightBooking,
            width: 11,
            height: 7,
            fit: BoxFit.contain,
            color: AppColor.orangeLight,
            filterQuality: FilterQuality.medium,
          ),
        ],
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  static const double _size = 24;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: selected ? AppColor.orangeLight : AppColor.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColor.orangeLight : AppColor.border,
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: AppColor.surface)
          : null,
    );
  }
}
