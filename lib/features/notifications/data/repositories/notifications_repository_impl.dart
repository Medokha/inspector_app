import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/api_mappers.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<NotificationItemEntity>> getNotifications() async {
    final json = await _api.get('/api/Notifications/me');
    final items = json is List ? JsonMap.mapList(json) : JsonMap.mapList(JsonMap.map(json)['items']);
    return items.map(ApiMappers.notification).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final json = await _api.get('/api/Notifications/me');
    if (json is Map) {
      final count = json['unreadCount'];
      if (count is num) return count.toInt();
    }
    final items = await getNotifications();
    return items.where((item) => item.isUnread).length;
  }

  @override
  Future<void> markAsRead(String id) {
    return _api.patch('/api/Notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() {
    return _api.post('/api/Notifications/me/read-all');
  }
}
