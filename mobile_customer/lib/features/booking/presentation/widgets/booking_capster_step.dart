import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/features/booking/presentation/widgets/booking_step_shell.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class BookingCapsterStep extends StatelessWidget {
  const BookingCapsterStep({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookingFlowProvider p = context.watch<BookingFlowProvider>();

    return BookingStepState(
      loading: false,
      error: null,
      isEmpty: p.capsters.isEmpty,
      emptyMessage: l10n.bookingCapsterEmpty,
      onRetry: p.loadSlots,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        itemCount: p.capsters.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final SlotCapster capster = p.capsters[index];
          return _CapsterCard(
            capster: capster,
            selected: p.capster?.id == capster.id,
            onTap: () => p.selectCapster(capster),
          );
        },
      ),
    );
  }
}

class _CapsterCard extends StatelessWidget {
  const _CapsterCard({
    required this.capster,
    required this.selected,
    required this.onTap,
  });

  static const double _avatar = 46;

  final SlotCapster capster;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BookingSelectCard(
      selected: selected,
      enabled: capster.available,
      tinted: false,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          _Avatar(url: capster.imageUrl, size: _avatar),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  capster.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Image.asset(
                      AppAssets.starDashboard,
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      capster.avgRating.toStringAsFixed(1),
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColor.inkSoft,
                      ),
                    ),
                  ],
                ),
                if (capster.available) ...<Widget>[
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF24A148),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l10n.bookingAvailableToday,
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 10.5,
                          color: const Color(0xFF24A148),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          BookingRadioDot(selected: selected),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? _fallback()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() => const ColoredBox(
    color: AppColor.border,
    child: Icon(Icons.person_rounded, size: 22, color: AppColor.surface),
  );
}
