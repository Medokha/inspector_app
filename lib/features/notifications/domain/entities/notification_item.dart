enum NotificationType {
  task,
  report,
  general,
}

class NotificationItemEntity {
  const NotificationItemEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
    required this.isUnread,
    this.url,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final NotificationType type;
  final bool isUnread;
  final String? url;
  final DateTime? createdAt;
}
