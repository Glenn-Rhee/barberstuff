import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/home/domain/dashboard_content.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class ActiveBookingCard extends StatelessWidget {
  const ActiveBookingCard({
    super.key,
    required this.booking,
    required this.onDetail,
  });

  final ActiveBooking booking;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();

    final String schedule =
        '${DateFormat('EEEE, d MMMM', locale).format(booking.schedule)}'
        ' • ${DateFormat('HH:mm', locale).format(booking.schedule)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.orangeLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.homeBookingUpcoming,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColor.surface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.homeBookingOrderId(booking.orderId),
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.inkFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColor.border.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.storeDashboard,
                    width: 20,
                    height: 20,
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
                  children: <Widget>[
                    Text(
                      booking.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.storeAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: AppColor.border),
          ),
          Row(
            children: <Widget>[
              _CapsterAvatar(photoUrl: booking.capsterPhotoUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      booking.capsterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDetail,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    l10n.homeBookingDetail,
                    style: AppTextStyle.labelMedium.copyWith(
                      color: AppColor.orangeLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapsterAvatar extends StatelessWidget {
  const _CapsterAvatar({required this.photoUrl});

  static const double _size = 34;

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = photoUrl;

    return ClipOval(
      child: SizedBox(
        width: _size,
        height: _size,
        child: url == null
            ? const ColoredBox(
                color: AppColor.border,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppColor.surface,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    const ColoredBox(
                      color: AppColor.border,
                      child: Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: AppColor.surface,
                      ),
                    ),
              ),
      ),
    );
  }
}
