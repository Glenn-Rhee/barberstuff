import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/notification/domain/entities/app_notification.dart';
import 'package:mobile_barberstuff/features/notification/presentation/widgets/notification_text.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  static const double _badge = 42;
  static const double _dot = 8;

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      splashColor: AppColor.goldDeep.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: _badge,
              height: _badge,
              decoration: BoxDecoration(
                color: AppColor.goldSoft.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  notificationIcon(notification.category),
                  width: 21,
                  height: 21,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    notificationTitle(notification.category, l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.titleSmall.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notificationBody(notification.category, l10n),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall.copyWith(
                      fontSize: 10.5,
                      height: 1.42,
                      color: AppColor.inkFaint,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notificationAge(notification.createdAt, l10n),
                    maxLines: 1,
                    style: AppTextStyle.bodySmall.copyWith(
                      fontSize: 10.5,
                      color: AppColor.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: _dot,
              child: notification.isRead
                  ? null
                  : Container(
                      width: _dot,
                      height: _dot,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppColor.goldMid,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
