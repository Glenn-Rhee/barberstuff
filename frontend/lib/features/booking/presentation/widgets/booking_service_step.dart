import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingServiceStep extends StatelessWidget {
  const BookingServiceStep({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();
    final BookingCatalog catalog = context.watch<BookingCatalog>();

    final List<BookingService> singles = catalog.servicesOf(ServiceKind.single);
    final List<BookingService> packages = catalog.servicesOf(
      ServiceKind.package,
    );

    if (singles.isEmpty && packages.isEmpty) {
      return Center(
        child: Text(
          l10n.bookingServiceEmpty,
          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkFaint),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: <Widget>[
        if (singles.isNotEmpty) ...<Widget>[
          Text(l10n.bookingSingleServiceLabel, style: AppTextStyle.titleMedium),
          const SizedBox(height: 12),
          for (final BookingService service in singles) ...<Widget>[
            _ServiceTile(
              service: service,
              selected: p.serviceIds.contains(service.id),
              onTap: () => p.toggleService(service.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
        if (packages.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          InkWell(
            onTap: p.togglePackageSection,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      l10n.bookingPackageLabel,
                      style: AppTextStyle.titleMedium,
                    ),
                  ),
                  Icon(
                    p.packageExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColor.ink,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (p.packageExpanded)
            for (final BookingService service in packages) ...<Widget>[
              _ServiceTile(
                service: service,
                selected: p.serviceIds.contains(service.id),
                onTap: () => p.toggleService(service.id),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final BookingService service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColor.orangeDashboard.withValues(alpha: 0.14)
          : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColor.orangeLight : AppColor.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Checkbox(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(service.name, style: AppTextStyle.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      service.description,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                PriceFormat.short(service.price),
                style: AppTextStyle.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.selected});

  static const double _size = 22;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: selected ? AppColor.orangeLight : AppColor.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: selected ? AppColor.orangeLight : AppColor.border,
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: AppColor.surface)
          : null,
    );
  }
}
