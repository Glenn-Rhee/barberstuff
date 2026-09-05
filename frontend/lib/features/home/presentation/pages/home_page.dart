import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/home/domain/dashboard_content.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/active_booking_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/benefit_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/birthday_promo_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_header.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/history_tile.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/nearby_store_list.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/points_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/quick_action_row.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/section_header.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/box_loader.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onProfileTap});

  static const double sidePadding = 20;
  static const int birthdayDiscount = 30;

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final ProfileProvider p = context.watch<ProfileProvider>();
    final CustomerProfile? profile = p.profile;

    return Column(
      children: <Widget>[
        DashboardHeader(
          name: profile?.name ?? '',
          photoUrl: profile?.imageUrl,
          onNotificationTap: () {
            showComingSoonDialog(context);
          },
          onProfileTap: onProfileTap ?? () {},
        ),
        Expanded(
          child: ColoredBox(
            color: AppColor.surface,
            child: profile == null
                ? _PlaceholderBody(provider: p)
                : _DashboardBody(profile: profile, onRefresh: p.load),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.profile, required this.onRefresh});

  final CustomerProfile profile;
  final Future<void> Function() onRefresh;

  static final ActiveBooking _booking = ActiveBooking(
    orderId: '0001',
    storeName: 'Pondok Gede',
    storeAddress:
        'Gg. Leopard Jl. Jatimakmur No.49C, RT.001/RW.011, Jatimakmur, Kec. Pd. Gede, Kota Bks, Jawa Barat 17413',
    capsterName: 'Danarmas',
    schedule: DateTime(2024, 5, 25, 16),
  );

  static const List<NearbyStore> _stores = <NearbyStore>[
    NearbyStore(
      id: '1',
      name: 'Depok',
      rating: 4.7,
      distanceKm: 3.2,
      imageAsset: AppAssets.storeDepok,
    ),
    NearbyStore(
      id: '2',
      name: 'Ciracas',
      rating: 4.8,
      distanceKm: 0.5,
      imageAsset: AppAssets.storeCiracas,
    ),
    NearbyStore(
      id: '3',
      name: 'Pondok Gede',
      rating: 4.6,
      distanceKm: 5.1,
      imageAsset: AppAssets.storePondokgede,
    ),
  ];

  static final List<HaircutHistory> _histories = <HaircutHistory>[
    HaircutHistory(
      id: '1',
      capsterName: 'Danarmas',
      date: DateTime(2026, 2, 30),
      storeName: 'Depok',
      price: 95000,
    ),
    HaircutHistory(
      id: '2',
      capsterName: 'Kang iqbal',
      date: DateTime(2026, 0, 28),
      storeName: 'Pondok Gede',
      price: 55000,
    ),
    HaircutHistory(
      id: '3',
      capsterName: 'Mas Ariel',
      date: DateTime(2026, 5, 8),
      storeName: 'Ciracas',
      price: 25000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColor.orangeLight,
      child: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 28),
        children: <Widget>[
          _Inset(
            child: PointsCard(
              points: profile.memberPoints,
              pointsToNextTier: profile.pointsToNextTier,
              progress: profile.tierProgress,
              tier: profile.tier,
              onTap: () {
                showComingSoonDialog(context);
              },
            ),
          ),
          const SizedBox(height: 16),
          _Inset(
            child: BirthdayPromoCard(
              discountPercent: HomePage.birthdayDiscount,
              onSeePromo: () {
                showComingSoonDialog(context);
              },
            ),
          ),

          const SizedBox(height: 26),
          _Inset(
            child: QuickActionRow(
              onSelect: (QuickAction _) {
                showComingSoonDialog(context);
              },
            ),
          ),

          const SizedBox(height: 28),
          _Inset(child: SectionHeader(title: l10n.homeBenefitTitle)),
          const SizedBox(height: 12),
          const _Inset(child: BenefitCard()),

          const SizedBox(height: 28),
          _Inset(child: SectionHeader(title: l10n.homeActiveBookingTitle)),
          const SizedBox(height: 12),
          _Inset(
            child: ActiveBookingCard(
              booking: _booking,
              onDetail: () {
                showComingSoonDialog(context);
              },
            ),
          ),

          const SizedBox(height: 28),
          _Inset(
            child: SectionHeader(
              title: l10n.homeNearbyTitle,
              actionLabel: l10n.homeNearbySeeAll,
              onAction: () {
                showComingSoonDialog(context);
              },
            ),
          ),
          const SizedBox(height: 12),
          NearbyStoreList(
            stores: _stores,
            horizontalPadding: HomePage.sidePadding,
            onSelect: (NearbyStore _) {
              showComingSoonDialog(context);
            },
          ),

          const SizedBox(height: 28),
          _Inset(
            child: SectionHeader(
              title: l10n.homeHistoryTitle,
              actionLabel: l10n.homeHistorySeeAll,
              onAction: () {
                showComingSoonDialog(context);
              },
            ),
          ),
          const SizedBox(height: 12),
          for (final HaircutHistory history in _histories) ...<Widget>[
            _Inset(
              child: HistoryTile(
                history: history,
                onTap: () {
                  showComingSoonDialog(context);
                },
              ),
            ),
            const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: HomePage.sidePadding),
      child: child,
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isFirstLoad) {
      return const Center(child: BoxLoader());
    }

    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              provider.error?.message(l10n) ?? l10n.exceptionDefault,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
            ),
            const SizedBox(height: 20),
            BoxButton(label: l10n.commonRetry, onPressed: provider.load),
          ],
        ),
      ),
    );
  }
}
