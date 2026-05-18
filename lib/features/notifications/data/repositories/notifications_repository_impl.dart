import 'package:inspector_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<List<NotificationItemEntity>> getNotifications() async {
    final list = await _remote.getNotifications();
    return list.map((json) {
      final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
      final title = json['title']?.toString() ?? '';
      return NotificationItemEntity(
        id: json['id']?.toString() ?? '',
        title: title,
        body: json['body']?.toString() ?? '',
        timeLabel: _formatTimeLabel(createdAt),
        type: _parseType(json['type']?.toString(), title),
        isUnread: !(json['isRead'] as bool? ?? true),
        url: json['url']?.toString(),
        createdAt: createdAt,
      );
    }).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n.isUnread).length;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _remote.markAsRead(id);
  }

  String _formatTimeLabel(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return '${date.day}/${date.month}/${date.year}';
  }

  NotificationType _parseType(String? type, String title) {
    if (type == 'task') return NotificationType.task;
    if (type == 'report') return NotificationType.report;
    
    // Fallback: parse based on title if type is not recognized or not provided
    if (title.contains('تقرير')) return NotificationType.report;
    if (title.contains('مهمة') || title.contains('مهام') || title.contains('اعتماد') || title.contains('صيانة') || title.contains('تنبيه')) {
      return NotificationType.task;
    }
    return NotificationType.general;
  }
}
