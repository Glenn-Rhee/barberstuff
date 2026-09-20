import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/features/notification/domain/app_notification.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

String notificationTitle(NotificationCategory category, AppLocalizations l10n) {
  switch (category) {
    case NotificationCategory.booking:
      return l10n.notificationBookingTitle;
    case NotificationCategory.points:
      return l10n.notificationPointsTitle;
    case NotificationCategory.membership:
      return l10n.notificationMembershipTitle;
    case NotificationCategory.recommendation:
      return l10n.notificationRecommendationTitle;
  }
}

String notificationBody(NotificationCategory category, AppLocalizations l10n) {
  switch (category) {
    case NotificationCategory.booking:
      return l10n.notificationBookingBody;
    case NotificationCategory.points:
      return l10n.notificationPointsBody;
    case NotificationCategory.membership:
      return l10n.notificationMembershipBody;
    case NotificationCategory.recommendation:
      return l10n.notificationRecommendationBody;
  }
}

String notificationIcon(NotificationCategory category) {
  switch (category) {
    case NotificationCategory.booking:
      return AppAssets.bookNotify;
    case NotificationCategory.points:
      return AppAssets.ticketPromo;
    case NotificationCategory.membership:
      return AppAssets.megaphoneNotify;
    case NotificationCategory.recommendation:
      return AppAssets.fileNotify;
  }
}

String notificationAge(DateTime createdAt, AppLocalizations l10n) {
  final Duration age = DateTime.now().difference(createdAt);

  if (age.inMinutes < 1) return l10n.notificationTimeNow;
  if (age.inMinutes < 60) return l10n.notificationTimeMinute(age.inMinutes);
  if (age.inHours < 24) return l10n.notificationTimeHour(age.inHours);
  return l10n.notificationTimeDay(age.inDays);
}
