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
    this.taskId,
  });

  final String id;
  final String title;
  final String timeLabel;
  final NotificationType type;
  final bool isUnread;
  final String? taskId;

  NotificationItemEntity copyWith({bool? isUnread}) {
    return NotificationItemEntity(
      id: id,
      title: title,
      timeLabel: timeLabel,
      type: type,
      isUnread: isUnread ?? this.isUnread,
      taskId: taskId,
    );
  }
}
