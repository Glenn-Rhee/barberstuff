import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/deeplink/store_link.dart';
import 'package:mobile_barberstuff/core/network/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/utils/launch_external.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_capsters.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_services.dart';
import 'package:mobile_barberstuff/features/store/presentation/provider/store_detail_provider.dart';
import 'package:mobile_barberstuff/features/store/presentation/utils/store_map_links.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/barber_cards.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_action_button.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_barber_list.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_book_bar.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_detail_header.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_detail_layout.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_detail_skeleton.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_tab_bar.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/section_title.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/store_see_all_sheet.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/tabs/store_tab_body.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/error_retry_view.dart';
import 'package:mobile_barberstuff/shared/widgets/navigation/app_back_bar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class StoreDetailArgs {
  const StoreDetailArgs({required this.storeId, this.initialTab});

  final String storeId;

  /// Tab yang langsung terbuka, misalnya masuk dari pintasan Paket.
  final StoreTab? initialTab;
}

class StoreDetailPage extends StatelessWidget {
  const StoreDetailPage({super.key, required this.args});

  final StoreDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreDetailProvider>(
      create: (BuildContext ctx) => StoreDetailProvider(
        ctx.read<GetStoreDetail>(),
        ctx.read<GetStoreCapsters>(),
        ctx.read<GetStoreServices>(),
        args.storeId,
        initialTab: args.initialTab ?? StoreTab.about,
      ),
      child: const _StoreDetailView(),
    );
  }
}

class _StoreDetailView extends StatelessWidget {
  const _StoreDetailView();

  static const double _sidePadding = StoreDetailLayout.sidePadding;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StoreDetailProvider p = context.watch<StoreDetailProvider>();
    final StoreDetail? detail = p.detail;

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBackBar(title: l10n.storeDetailTitle),
      bottomNavigationBar: detail == null
          ? null
          : StoreBookBar(detail: detail, onBook: () => _book(context, detail)),
      body: SafeArea(
        top: false,
        child: p.isLoading && detail == null
            ? const StoreDetailSkeleton()
            : detail == null
            ? ErrorRetryView(
                message: p.error?.message(l10n) ?? l10n.exceptionDefault,
                onRetry: p.load,
              )
            : RefreshIndicator(
                onRefresh: p.load,
                color: AppColor.goldDeep,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 28),
                  children: <Widget>[
                    StoreDetailBanner(url: detail.bannerUrl),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _sidePadding,
                        16,
                        _sidePadding,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StoreDetailInfo(detail: detail),
                          const SizedBox(height: 18),
                          _ActionRow(
                            onCall: () => _call(detail),
                            onRoute: () => _openMap(detail),
                            onShare: () => _share(context, detail),
                          ),
                          const SizedBox(height: 22),
                          SectionTitle(
                            title: l10n.storeBarbers,
                            actionLabel: l10n.storeSeeAll,
                            onAction: () => _showBarbers(context, p.capsters),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    StoreBarberList(capsters: p.capsters),
                    const SizedBox(height: 16),
                    StoreTabBar(active: p.tab, onSelect: p.setTab),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _sidePadding,
                      ),
                      child: StoreTabBody(
                        provider: p,
                        detail: detail,
                        onBook: () => _book(context, detail),
                        onOpenMap: () => _openMap(detail),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Aksi
  // ---------------------------------------------------------------------------

  Future<void> _call(StoreDetail detail) async {
    if (detail.phoneNumber.isEmpty) return;
    await launchExternal(Uri.parse('tel:${detail.phoneNumber}'));
  }

  Future<void> _openMap(StoreDetail detail) async {
    await launchExternal(await mapUriFor(detail));
  }

  /// Buka lembar bagikan bawaan HP (WhatsApp, Telegram, dll) berisi
  /// tautan https yang bisa diklik dan langsung membuka cabang ini.
  Future<void> _share(BuildContext context, StoreDetail detail) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String text = l10n.storeShareMessage(
      detail.name,
      detail.address,
      StoreLink.forStore(detail.id).toString(),
    );

    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: detail.name),
      );
    } on Object catch (_) {
      // Lembar bagikan gagal terbuka: salin saja supaya tetap bisa ditempel.
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      AppToast.show(context, message: l10n.storeShareCopied);
    }
  }

  /// Booking langsung di cabang ini, langkah pilih cabang dilewati. Cabang
  /// yang tutup juga tidak bisa dipilih di daftar cabang, jadi ditolak di sini.
  void _book(BuildContext context, StoreDetail detail) {
    if (!detail.isOpen) {
      AppToast.show(
        context,
        message: AppLocalizations.of(context).storeBookClosed,
      );
      return;
    }

    Navigator.of(
      context,
    ).pushNamed(AppRoute.booking, arguments: detail.toSummary());
  }

  void _showBarbers(BuildContext context, List<CapsterItem> capsters) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    showStoreSeeAllSheet(
      context,
      title: l10n.storeBarbers,
      emptyMessage: l10n.storeNoBarber,
      itemCount: capsters.length,
      itemBuilder: (BuildContext _, int index) =>
          BarberTile(capster: capsters[index]),
    );
  }
}

/// Tiga tombol bulat: telepon, rute, bagikan.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onCall,
    required this.onRoute,
    required this.onShare,
  });

  final VoidCallback onCall;
  final VoidCallback onRoute;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StoreActionButton(
          iconPath: AppAssets.phoneIcon,
          label: l10n.storeActionCall,
          onTap: onCall,
        ),
        StoreActionButton(
          iconPath: AppAssets.routeDetailStore,
          label: l10n.storeActionRoute,
          onTap: onRoute,
        ),
        StoreActionButton(
          iconPath: AppAssets.shareDetailStore,
          label: l10n.storeActionShare,
          onTap: onShare,
        ),
      ],
    );
  }
}
