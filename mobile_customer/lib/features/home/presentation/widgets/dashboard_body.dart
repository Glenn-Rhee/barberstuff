import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/home/presentation/models/dashboard_content.dart';
import 'package:mobile_barberstuff/features/home/presentation/provider/dashboard_provider.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/active_booking_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/benefit_carousel.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/birthday_promo_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/history_tile.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/nearby_store_list.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/points_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/quick_action_row.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/section_header.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/promo/presentation/pages/promo_page.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

import 'package:mobile_barberstuff/shared/widgets/navigation/dashboard_bottom_nav.dart';
import 'package:provider/provider.dart';

/// Isi beranda setelah profil termuat: promo ulang tahun, poin, pintasan,
/// benefit, booking aktif, cabang terdekat, lalu riwayat.
class DashboardBody extends StatelessWidget {
  const DashboardBody({
    super.key,
    required this.profile,
    required this.onRefresh,
    required this.controller,
    this.onHistoryTap,
  });

  final CustomerProfile profile;
  final Future<void> Function() onRefresh;
  final ScrollController controller;
  final VoidCallback? onHistoryTap;

  static const double sidePadding = 12;
  static const int birthdayDiscount = 30;

  static List<BenefitItem> _benefitsOf(AppLocalizations l10n) {
    return <BenefitItem>[
      BenefitItem(
        title: l10n.homeBenefitDiscountTitle,
        description: l10n.homeBirthdayDescription,
        imageAsset: AppAssets.promoScissors,
      ),
      BenefitItem(
        title: l10n.homeBenefitPointsTitle,
        description: l10n.homeBenefitPoints,
        imageAsset: AppAssets.promoScissors,
      ),
      BenefitItem(
        title: l10n.homeBenefitPriorityTitle,
        description: l10n.homeBenefitPriority,
        imageAsset: AppAssets.promoScissors,
      ),
    ];
  }

  void _openBooking(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoute.booking);
  }

  void _openPromo(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamed(AppRoute.promo, arguments: PromoArgs(profile: profile));
  }

  void _openPackage(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoute.storeList);
  }

  void _openReceipt(BuildContext context, BookingRecord record) {
    Navigator.of(context).pushNamed(AppRoute.bookingReceipt, arguments: record);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DashboardProvider dashboard = context.watch<DashboardProvider>();

    final BookingRecord? upcoming = dashboard.upcoming;
    final List<BookingRecord> histories = dashboard.history;
    final List<NearbyStore> stores = dashboard.stores
        .map(
          (StoreSummary s) =>
              NearbyStore.fromSummary(s, distanceKm: dashboard.distanceOf(s)),
        )
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait(<Future<void>>[onRefresh(), dashboard.load()]);
      },
      color: AppColor.goldDeep,
      child: ListView(
        controller: controller,
        padding: EdgeInsets.only(
          top: 20,
          bottom: DashboardBottomNav.spaceOf(context),
        ),
        children: <Widget>[
          _Inset(
            child: BirthdayPromoCard(
              discountPercent: birthdayDiscount,
              onBooking: () => _openBooking(context),
            ),
          ),

          const SizedBox(height: 16),
          _Inset(
            child: PointsCard(
              points: profile.memberPoints,
              tier: profile.tier,
              onTap: () => _openPromo(context),
            ),
          ),

          const SizedBox(height: 26),
          _Inset(
            child: QuickActionRow(
              onSelect: (QuickAction action) {
                switch (action) {
                  case QuickAction.booking:
                    _openBooking(context);
                  case QuickAction.package:
                    _openPackage(context);
                  case QuickAction.promo:
                    _openPromo(context);
                  case QuickAction.history:
                    if (onHistoryTap != null) {
                      onHistoryTap!.call();
                    } else {
                      Navigator.of(context).pushNamed(AppRoute.history);
                    }
                }
              },
            ),
          ),

          const SizedBox(height: 28),
          _Inset(child: SectionHeader(title: l10n.homeBenefitTitle)),
          const SizedBox(height: 12),
          BenefitCarousel(
            benefits: _benefitsOf(l10n),
            horizontalPadding: sidePadding,
          ),

          if (upcoming != null) ...<Widget>[
            const SizedBox(height: 28),
            _Inset(child: SectionHeader(title: l10n.homeActiveBookingTitle)),
            const SizedBox(height: 12),
            _Inset(
              child: ActiveBookingCard(
                booking: ActiveBooking.fromRecord(upcoming),
                onDetail: () => _openReceipt(context, upcoming),
              ),
            ),
          ],

          if (stores.isNotEmpty) ...<Widget>[
            const SizedBox(height: 28),
            _Inset(
              child: SectionHeader(
                title: l10n.homeNearbyTitle,
                actionLabel: l10n.homeNearbySeeAll,
                onAction: () =>
                    Navigator.of(context).pushNamed(AppRoute.storeList),
              ),
            ),
            const SizedBox(height: 12),
            NearbyStoreList(
              stores: stores,
              horizontalPadding: sidePadding,
              onSelect: (NearbyStore store) => Navigator.of(context).pushNamed(
                AppRoute.storeDetail,
                arguments: StoreDetailArgs(storeId: store.id),
              ),
              onBooking: (NearbyStore _) => _openBooking(context),
            ),
          ],

          if (histories.isNotEmpty) ...<Widget>[
            const SizedBox(height: 28),
            _Inset(
              child: SectionHeader(
                title: l10n.homeHistoryTitle,
                actionLabel: l10n.homeHistorySeeAll,
                onAction:
                    onHistoryTap ??
                    () => Navigator.of(context).pushNamed(AppRoute.history),
              ),
            ),
            const SizedBox(height: 12),
            for (final BookingRecord record in histories) ...<Widget>[
              _Inset(
                child: HistoryTile(
                  history: HaircutHistory.fromRecord(record),
                  onTap: () => _openReceipt(context, record),
                  onRebook: () => _openBooking(context),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _Inset extends StatelessWidget {
  const _Inset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardBody.sidePadding,
      ),
      child: child,
    );
  }
}
