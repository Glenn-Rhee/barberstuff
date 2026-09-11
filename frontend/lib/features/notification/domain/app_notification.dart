enum NotificationCategory { booking, points, membership, recommendation }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
