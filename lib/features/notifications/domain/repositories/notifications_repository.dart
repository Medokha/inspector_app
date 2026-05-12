import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItemEntity>> getNotifications();
  Future<int> getUnreadCount();
}
