import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/permission_prompt.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/home/domain/dashboard_content.dart';
import 'package:mobile_barberstuff/features/home/presentation/provider/dashboard_provider.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/active_booking_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/benefit_carousel.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/birthday_promo_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/dashboard_header.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/history_tile.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/nearby_store_list.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/points_card.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/quick_action_row.dart';
import 'package:mobile_barberstuff/features/home/presentation/widgets/section_header.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile_barberstuff/features/promo/presentation/pages/promo_page.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/box_loader.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onProfileTap, this.onHistoryTap});

  static const double sidePadding = 12;
  static const int birthdayDiscount = 30;

  final VoidCallback? onProfileTap;
  final VoidCallback? onHistoryTap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Di bawah ambang ini header selalu penuh, supaya tidak berkedip di puncak.
  static const double _collapseThreshold = 12;

  final ScrollController _scroll = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _askPermissions();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;

    final bool next =
        _scroll.offset > _collapseThreshold &&
        _scroll.position.userScrollDirection == ScrollDirection.reverse;

    if (next != _collapsed) setState(() => _collapsed = next);
  }

  Future<void> _askPermissions() async {
    if (!mounted) return;
    await PermissionPrompt.askNotification(context);
    if (!mounted) return;
    await PermissionPrompt.askLocation(context);
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider p = context.watch<ProfileProvider>();
    final CustomerProfile? profile = p.profile;

    return Column(
      children: <Widget>[
        DashboardHeader(
          name: profile?.name ?? '',
          photoUrl: profile?.imageUrl,
          collapsed: _collapsed,
          onNotificationTap: () {
            Navigator.of(context).pushNamed(AppRoute.notification);
          },
          onProfileTap: widget.onProfileTap ?? () {},
        ),
        Expanded(
          child: ColoredBox(
            color: AppColor.surface,
            child: profile == null
                ? _PlaceholderBody(provider: p)
                : _DashboardBody(
                    profile: profile,
                    onRefresh: p.load,
                    controller: _scroll,
                    onHistoryTap: widget.onHistoryTap,
                  ),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.profile,
    required this.onRefresh,
    required this.controller,
    this.onHistoryTap,
  });

  final CustomerProfile profile;
  final Future<void> Function() onRefresh;
  final ScrollController controller;
  final VoidCallback? onHistoryTap;

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
          bottom: 28 + DashboardBottomNav.spaceOf(context),
        ),
        children: <Widget>[
          _Inset(
            child: BirthdayPromoCard(
              discountPercent: HomePage.birthdayDiscount,
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
                  case QuickAction.package:
                    _openBooking(context);
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
            horizontalPadding: HomePage.sidePadding,
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
            _Inset(child: SectionHeader(title: l10n.homeNearbyTitle)),
            const SizedBox(height: 12),
            NearbyStoreList(
              stores: stores,
              horizontalPadding: HomePage.sidePadding,
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
