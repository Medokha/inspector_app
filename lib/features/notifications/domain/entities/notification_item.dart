enum NotificationType {
  task,
  report,
  general,
}

class NotificationItemEntity {
  const NotificationItemEntity({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.type,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String timeLabel;
  final NotificationType type;
  final bool isUnread;
}
