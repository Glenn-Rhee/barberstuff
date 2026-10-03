import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/section_title.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/store_map_preview.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class StoreAboutTab extends StatelessWidget {
  const StoreAboutTab({
    super.key,
    required this.detail,
    required this.onOpenMap,
  });

  final StoreDetail detail;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime? open = detail.openHour;
    final DateTime? close = detail.closeHour;

    final String hours = open == null || close == null
        ? '-'
        : '${DateFormat('HH.mm').format(open)} - '
              '${DateFormat('HH.mm').format(close)} WIB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionTitle(title: l10n.storeDescription),
        const SizedBox(height: 8),
        Text(
          detail.description.isEmpty ? '-' : detail.description,
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 12.5,
            height: 1.6,
            color: AppColor.inkSoft,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Divider(height: 1, thickness: 1, color: AppColor.border),
        ),
        SectionTitle(title: l10n.storeHours),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.storeHoursEveryday,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: AppColor.inkSoft,
                ),
              ),
            ),
            Text(
              hours,
              style: AppTextStyle.titleSmall.copyWith(fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionTitle(
          title: l10n.storeAddressTitle,
          actionLabel: l10n.storeSeeMap,
          onAction: onOpenMap,
        ),
        const SizedBox(height: 8),
        Text(
          detail.address,
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 12,
            color: AppColor.inkFaint,
          ),
        ),
        const SizedBox(height: 12),
        _MapCard(detail: detail, onTap: onOpenMap),
      ],
    );
  }
}

/// Peta asli kalau koordinat tersedia; kalau tidak, jatuh ke tombol polos.
class _MapCard extends StatelessWidget {
  const _MapCard({required this.detail, required this.onTap});

  final StoreDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StoreCoordinate? at = detail.coordinate;

    if (at != null) {
      return StoreMapPreview(
        storeLatitude: at.latitude,
        storeLongitude: at.longitude,
        userPosition: context.read<LocationService>().lastKnown,
        onTap: onTap,
      );
    }

    return Material(
      color: AppColor.border.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 130,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                AppAssets.routeDetailStore,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                color: AppColor.goldDeep,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.storeSeeMap,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColor.goldDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
