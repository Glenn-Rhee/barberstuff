import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/section_title.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/store_see_all_sheet.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class StoreProductTab extends StatelessWidget {
  const StoreProductTab({
    super.key,
    required this.title,
    required this.items,
    required this.emptyMessage,
    required this.isPackage,
    required this.onBook,
  });

  final String title;
  final List<ServiceItem> items;
  final String emptyMessage;
  final bool isPackage;
  final VoidCallback onBook;

  /// Tab cukup menampilkan beberapa teratas, sisanya lewat "Lihat Semua".
  static const int previewCount = 3;

  void _showAll(BuildContext context) {
    showStoreSeeAllSheet(
      context,
      title: title,
      emptyMessage: emptyMessage,
      itemCount: items.length,
      itemBuilder: (BuildContext sheetContext, int index) => _ProductCard(
        item: items[index],
        isPackage: isPackage,
        onBook: () {
          // Tutup daftarnya dulu supaya booking tidak terbuka di bawah sheet.
          Navigator.of(sheetContext).pop();
          onBook();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionTitle(
          title: title,
          actionLabel: l10n.storeSeeAll,
          onAction: () => _showAll(context),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                emptyMessage,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.inkFaint,
                ),
              ),
            ),
          )
        else
          for (final ServiceItem item in items.take(previewCount)) ...<Widget>[
            _ProductCard(item: item, isPackage: isPackage, onBook: onBook),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.isPackage,
    required this.onBook,
  });

  final ServiceItem item;
  final bool isPackage;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? description = item.description;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          if (isPackage) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 54,
                height: 54,
                color: AppColor.border.withValues(alpha: 0.5),
                child: Image.asset(
                  AppAssets.promoScissors,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  description == null || description.isEmpty
                      ? l10n.storeTypeCount(1)
                      : description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColor.inkFaint,
                  ),
                ),
                if (isPackage) ...<Widget>[
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          formatRupiah(item.price),
                          style: AppTextStyle.titleSmall.copyWith(
                            fontSize: 13,
                            color: AppColor.goldDeep,
                          ),
                        ),
                      ),
                      _BookButton(label: l10n.storeBookNow, onTap: onBook),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isPackage) ...<Widget>[
            const SizedBox(width: 10),
            Text(
              formatRupiah(item.price),
              style: AppTextStyle.titleSmall.copyWith(
                fontSize: 13,
                color: AppColor.goldDeep,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookButton extends StatelessWidget {
  const _BookButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.goldDeep,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyle.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColor.surface,
            ),
          ),
        ),
      ),
    );
  }
}
