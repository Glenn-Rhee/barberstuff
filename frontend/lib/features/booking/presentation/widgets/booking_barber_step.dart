import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingBarberStep extends StatelessWidget {
  const BookingBarberStep({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();
    final List<BookingCapster> capsters = p.capsters;

    if (capsters.isEmpty) {
      return Center(
        child: Text(
          l10n.bookingCapsterEmpty,
          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkFaint),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scale = MediaQuery.textScalerOf(context).scale(1);
        final int columns = constraints.maxWidth >= 560 ? 3 : 2;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1 / (1.18 + (scale - 1) * 0.22),
          ),
          itemCount: capsters.length,
          itemBuilder: (BuildContext context, int index) {
            final BookingCapster capster = capsters[index];
            return _CapsterCard(
              capster: capster,
              selected: p.capsterId == capster.id,
              onTap: () => p.selectCapster(capster.id),
            );
          },
        );
      },
    );
  }
}

class _CapsterCard extends StatelessWidget {
  const _CapsterCard({
    required this.capster,
    required this.selected,
    required this.onTap,
  });

  final BookingCapster capster;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final NumberFormat decimal = NumberFormat('0.0', 'en');

    return Material(
      color: selected
          ? AppColor.orangeDashboard.withValues(alpha: 0.18)
          : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColor.orangeLight : AppColor.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: Image.asset(
                      capster.photoAsset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                          const ColoredBox(
                            color: AppColor.border,
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColor.surface,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                capster.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle.titleSmall,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    AppAssets.starDashboard,
                    width: 13,
                    height: 13,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    decimal.format(capster.rating),
                    style: AppTextStyle.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
