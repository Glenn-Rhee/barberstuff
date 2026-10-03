import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/presentation/provider/store_detail_provider.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_detail_layout.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

extension StoreTabLabel on StoreTab {
  String label(AppLocalizations l10n) {
    switch (this) {
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
}

/// Deretan chip Tentang / Layanan / Paket / Ulasan yang bisa digeser.
class StoreTabBar extends StatelessWidget {
  const StoreTabBar({super.key, required this.active, required this.onSelect});

  final StoreTab active;
  final ValueChanged<StoreTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 40 * StoreDetailLayout.textScale(context),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: StoreDetailLayout.sidePadding,
        ),
        children: <Widget>[
          for (final StoreTab tab in StoreTab.values) ...<Widget>[
            _StoreTabChip(
              label: tab.label(l10n),
              active: active == tab,
              onTap: () => onSelect(tab),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _StoreTabChip extends StatelessWidget {
  const _StoreTabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColor.goldDeep : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: AppColor.goldDeep),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyle.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColor.surface : AppColor.goldDeep,
            ),
          ),
        ),
      ),
    );
  }
}
