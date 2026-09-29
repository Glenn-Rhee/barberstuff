import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/price_format.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.item, required this.onReview});

  final BookingHistory item;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String subtitle =
        '${DateFormat('EEEE, d MMM y', locale).format(item.date)}'
        ' - ${item.storeName}';

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: <Widget>[
          _TopRow(item: item, subtitle: subtitle),
          if (item.status == BookingStatus.completed) ...<Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 1, color: AppColor.border),
            ),
            _ReviewRow(item: item, onReview: onReview),
          ],
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.item, required this.subtitle});

  final BookingHistory item;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.border.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Image.asset(
              AppAssets.scissorsDashboard,
              width: 19,
              height: 19,
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
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      item.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColor.inkFaint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          formatRupiah(item.price),
          maxLines: 1,
          style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    late final String label;
    late final Color background;
    late final Color foreground;

    switch (status) {
      case BookingStatus.completed:
        label = l10n.historyBadgeDone;
        background = const Color(0xFFE3F5E9);
        foreground = const Color(0xFF2E9E5B);
      case BookingStatus.canceled:
        label = l10n.historyBadgeCancel;
        background = const Color(0xFFFDE8EA);
        foreground = const Color(0xFFD8586B);
      case BookingStatus.booked:
      case BookingStatus.progress:
        label = l10n.historyBadgeProgress;
        background = const Color(0xFFE8ECFB);
        foreground = const Color(0xFF5566CC);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppTextStyle.labelSmall.copyWith(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: foreground,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.item, required this.onReview});

  final BookingHistory item;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool reviewed = item.isReviewed;

    return Row(
      children: <Widget>[
        if (reviewed) ...<Widget>[
          Image.asset(
            AppAssets.starHistoryFilled,
            width: 14,
            height: 14,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${item.reviewScore!.toStringAsFixed(1)} • '
              '${l10n.historyYourReview}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
            ),
          ),
        ] else
          Flexible(
            child: Text(
              l10n.historyNotReviewed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 11,
                color: AppColor.inkFaint,
              ),
            ),
          ),
        const Spacer(),
        GestureDetector(
          onTap: onReview,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                reviewed ? l10n.historySeeReview : l10n.historyWriteReview,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: reviewed ? AppColor.ink : AppColor.goldDeep,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(
                AppAssets.arrowLongIcon,
                width: 14,
                height: 10,
                fit: BoxFit.contain,
                color: reviewed ? AppColor.ink : AppColor.goldDeep,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
