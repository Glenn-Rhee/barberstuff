import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/steps/booking_step_shell.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingServiceStep extends StatelessWidget {
  const BookingServiceStep({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: _Tabs(
            current: p.serviceTab,
            serviceLabel: l10n.bookingTabService,
            packageLabel: l10n.bookingPackageLabel,
            onSelect: p.setServiceTab,
          ),
        ),
        Expanded(
          child: BookingStepState(
            loading: p.loadingServices,
            error: p.servicesError,
            isEmpty: p.visibleServices.isEmpty,
            emptyMessage: l10n.bookingServiceEmpty,
            onRetry: p.loadServices,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              itemCount: p.visibleServices.length,
              separatorBuilder: (BuildContext _, int _) =>
                  const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final ServiceItem item = p.visibleServices[index];
                return _ServiceCard(
                  item: item,
                  selected: p.isServiceSelected(item),
                  onTap: () => p.toggleService(item),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.current,
    required this.serviceLabel,
    required this.packageLabel,
    required this.onSelect,
  });

  final ProductType current;
  final String serviceLabel;
  final String packageLabel;
  final ValueChanged<ProductType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.border.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _TabItem(
              label: serviceLabel,
              active: current == ProductType.service,
              onTap: () => onSelect(ProductType.service),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: packageLabel,
              active: current == ProductType.package,
              onTap: () => onSelect(ProductType.package),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
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
      color: active ? AppColor.goldDeep : Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: AppTextStyle.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColor.surface : AppColor.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ServiceItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? description = item.description;

    return BookingSelectCard(
      selected: selected,
      enabled: item.isActive,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColor.goldSoft.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Image.asset(
                AppAssets.scissorsDashboard,
                width: 17,
                height: 17,
                fit: BoxFit.contain,
                color: AppColor.ink,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
                ),
                if (description != null && description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColor.inkFaint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatRupiah(item.price),
            maxLines: 1,
            style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
          ),
          const SizedBox(width: 10),
          BookingRadioDot(selected: selected),
        ],
      ),
    );
  }
}
