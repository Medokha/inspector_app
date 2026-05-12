import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';

class HomeOverview {
  const HomeOverview({
    required this.inspectorName,
    required this.region,
    required this.totalToday,
    required this.returnedCount,
    required this.activeTasks,
    required this.recentNotifications,
    required this.unreadNotifications,
  });

  final String inspectorName;
  final String region;
  final int totalToday;
  final int returnedCount;
  final List<TaskEntity> activeTasks;
  final List<NotificationItemEntity> recentNotifications;
  final int unreadNotifications;
}
