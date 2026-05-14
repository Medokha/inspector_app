import 'package:inspector_app/features/home/domain/entities/home_overview.dart';
import 'package:inspector_app/features/home/domain/repositories/home_repository.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';

import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._notificationsRepo, this._tasksRepo);

  final NotificationsRepository _notificationsRepo;
  final TasksRepository _tasksRepo;

  @override
  Future<HomeOverview> getOverview() async {
    // Fetch today's tasks
    final todayTasks = await _tasksRepo.getTasks(date: 'today');
    
    // Fetch returned tasks
    final returnedTasks = await _tasksRepo.getTasks(status: 'rejected');
    
    // Fetch real notifications from API
    final notifications = await _notificationsRepo.getNotifications();
    final unread = await _notificationsRepo.getUnreadCount();

    return HomeOverview(
      inspectorName: 'أحمد النجفي', 
      region: 'بغداد - الكرخ',
      totalToday: todayTasks.length,
      returnedCount: returnedTasks.length,
      activeTasks: todayTasks.take(5).toList(),
      recentNotifications: notifications.take(5).toList(),
      unreadNotifications: unread,
    );
  }
}
