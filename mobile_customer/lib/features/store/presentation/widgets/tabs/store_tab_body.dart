import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/presentation/provider/store_detail_provider.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/tabs/store_about_tab.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/tabs/store_product_tab.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/tabs/store_review_tab.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/feedback/skeleton.dart';

/// Isi tab yang sedang aktif di detail cabang.
class StoreTabBody extends StatelessWidget {
  const StoreTabBody({
    super.key,
    required this.provider,
    required this.detail,
    required this.onBook,
    required this.onOpenMap,
  });

  final StoreDetailProvider provider;
  final StoreDetail detail;
  final VoidCallback onBook;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (provider.isLoadingProducts) {
      return const SkeletonGroup(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: <Widget>[
              SkeletonListTile(thumbSize: 56, lines: 2),
              SizedBox(height: 10),
              SkeletonListTile(thumbSize: 56, lines: 2),
              SizedBox(height: 10),
              SkeletonListTile(thumbSize: 56, lines: 2),
            ],
          ),
        ),
      );
    }

    switch (provider.tab) {
      case StoreTab.about:
        return StoreAboutTab(detail: detail, onOpenMap: onOpenMap);
      case StoreTab.service:
        return StoreProductTab(
          title: l10n.storeServicesTitle,
          items: provider.services,
          emptyMessage: l10n.storeNoService,
          isPackage: false,
          onBook: onBook,
        );
      case StoreTab.package:
        return StoreProductTab(
          title: l10n.storePackagesTitle,
          items: provider.packages,
          emptyMessage: l10n.storeNoPackage,
          isPackage: true,
          onBook: onBook,
        );
      case StoreTab.review:
        return StoreReviewTab(detail: detail);
    }
  }
}
