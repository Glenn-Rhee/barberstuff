import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail.dart';
import 'package:mobile_barberstuff/features/store/data/repositories/store_repository.dart';
import 'package:mobile_barberstuff/features/store/presentation/provider/store_detail_provider.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/store_detail_parts.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/store_tab_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/box_loader.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreDetailArgs {
  const StoreDetailArgs({required this.storeId});

  final String storeId;
}

class StoreDetailPage extends StatelessWidget {
  const StoreDetailPage({super.key, required this.args});

  final StoreDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreDetailProvider>(
      create: (BuildContext ctx) => StoreDetailProvider(
        ctx.read<StoreRepository>(),
        ctx.read<BookingRepository>(),
        args.storeId,
      ),
      child: const _StoreDetailView(),
    );
  }
}

class _StoreDetailView extends StatelessWidget {
  const _StoreDetailView();

  static const double sidePadding = 20;

  static double _scaleOf(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);

  String _tabLabel(StoreTab tab, AppLocalizations l10n) {
    switch (tab) {
      case StoreTab.about:
        return l10n.storeTabAbout;
      case StoreTab.service:
        return l10n.storeTabService;
      case StoreTab.package:
        return l10n.storeTabPackage;
      case StoreTab.review:
        return l10n.storeTabReview;
    }
  }

  Future<void> _open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (_) {
      return;
    }
  }

  Future<void> _call(StoreDetail detail) async {
    if (detail.phoneNumber.isEmpty) return;
    await _open(Uri.parse('tel:${detail.phoneNumber}'));
  }

  Future<void> _route(StoreDetail detail) async {
    final StoreCoordinateLike? at = detail.coordinate == null
        ? null
        : StoreCoordinateLike(
            detail.coordinate!.latitude,
            detail.coordinate!.longitude,
          );

    final Uri uri = at == null
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query='
            '${Uri.encodeComponent(detail.address)}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query='
            '${at.latitude},${at.longitude}',
          );

    await _open(uri);
  }

  Future<void> _share(BuildContext context, StoreDetail detail) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    await Clipboard.setData(
      ClipboardData(text: '${detail.name}\n${detail.address}'),
    );
    if (!context.mounted) return;

    AppToast.show(context, message: l10n.storeShareCopied);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StoreDetailProvider p = context.watch<StoreDetailProvider>();
    final StoreDetail? detail = p.detail;

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Image.asset(
            AppAssets.backArrowIcon,
            width: 20,
            height: 16,
            fit: BoxFit.contain,
            color: AppColor.ink,
            filterQuality: FilterQuality.medium,
          ),
        ),
        title: Text(
          l10n.storeDetailTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: p.isLoading
            ? const Center(child: BoxLoader())
            : detail == null
            ? _ErrorBody(provider: p)
            : ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: <Widget>[
                  _Banner(url: detail.bannerUrl),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      sidePadding,
                      16,
                      sidePadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _TitleRow(detail: detail),
                        const SizedBox(height: 8),
                        _AddressRow(address: detail.address),
                        const SizedBox(height: 8),
                        _RatingRow(detail: detail),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            StoreActionButton(
                              iconPath: AppAssets.phoneIcon,
                              label: l10n.storeActionCall,
                              onTap: () => _call(detail),
                            ),
                            StoreActionButton(
                              iconPath: AppAssets.routeDetailStore,
                              label: l10n.storeActionRoute,
                              onTap: () => _route(detail),
                            ),
                            StoreActionButton(
                              iconPath: AppAssets.shareDetailStore,
                              label: l10n.storeActionShare,
                              onTap: () => _share(context, detail),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        SectionTitle(
                          title: l10n.storeBarbers,
                          actionLabel: l10n.storeSeeAll,
                          onAction: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Barbers(provider: p),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40 * _scaleOf(context),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: sidePadding,
                      ),
                      children: <Widget>[
                        for (final StoreTab tab in StoreTab.values) ...<Widget>[
                          StoreTabChip(
                            label: _tabLabel(tab, l10n),
                            active: p.tab == tab,
                            onTap: () => p.setTab(tab),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: sidePadding,
                    ),
                    child: _TabBody(provider: p, detail: detail),
                  ),
                ],
              ),
      ),
    );
  }
}

class StoreCoordinateLike {
  const StoreCoordinateLike(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.provider, required this.detail});

  final StoreDetailProvider provider;
  final StoreDetail detail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (provider.isLoadingProducts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: BoxLoader()),
      );
    }

    void openBooking() =>
        Navigator.of(context).pushNamed(AppRoute.booking);

    switch (provider.tab) {
      case StoreTab.about:
        return StoreAboutTab(
          detail: detail,
          onOpenMap: () => _openMap(detail),
        );
      case StoreTab.service:
        return StoreProductTab(
          title: l10n.storeServicesTitle,
          items: provider.services,
          emptyMessage: l10n.storeNoService,
          isPackage: false,
          onBook: openBooking,
        );
      case StoreTab.package:
        return StoreProductTab(
          title: l10n.storePackagesTitle,
          items: provider.packages,
          emptyMessage: l10n.storeNoPackage,
          isPackage: true,
          onBook: openBooking,
        );
      case StoreTab.review:
        return StoreReviewTab(detail: detail);
    }
  }

  Future<void> _openMap(StoreDetail detail) async {
    final Uri uri = detail.coordinate == null
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query='
            '${Uri.encodeComponent(detail.address)}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query='
            '${detail.coordinate!.latitude},${detail.coordinate!.longitude}',
          );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (_) {
      return;
    }
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.url});

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
              color: detail.isOpen
                  ? const Color(0xFF3A8DC4)
                  : AppColor.inkSoft,
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

class _Barbers extends StatelessWidget {
  const _Barbers({required this.provider});

  final StoreDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (provider.capsters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          l10n.storeNoBarber,
          style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
        ),
      );
    }

    return SizedBox(
      height: 52 * _StoreDetailView._scaleOf(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: provider.capsters.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) =>
            BarberChip(capster: provider.capsters[index]),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.provider});

  final StoreDetailProvider provider;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 18),
            BoxButton(label: l10n.commonRetry, onPressed: provider.load),
          ],
        ),
      ),
    );
  }
}
