import 'package:inspector_app/features/home/domain/entities/home_overview.dart';
import 'package:inspector_app/features/home/domain/repositories/home_repository.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';

import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._notificationsRepo);

  final NotificationsRepository _notificationsRepo;

  @override
  Future<HomeOverview> getOverview() async {
    final active = _tasks;
    final returned = _tasks.where((item) => item.status == TaskStatus.returned).toList();
    
    // Fetch real notifications from API
    final notifications = await _notificationsRepo.getNotifications();
    final unread = await _notificationsRepo.getUnreadCount();

    return HomeOverview(
      inspectorName: 'أحمد النجفي', // This should ideally come from SessionController
      region: 'بغداد - الكرخ',
      totalToday: 4,
      returnedCount: returned.length,
      activeTasks: active,
      recentNotifications: notifications.take(5).toList(),
      unreadNotifications: unread,
    );
  }
}

final List<TaskEntity> _tasks = <TaskEntity>[
  TaskEntity(
    id: 'WQF-2024-007',
    title: 'مسجد الرحمن - الكرخ',
    location: 'بغداد - الكرخ',
    status: TaskStatus.inProgress,
    timeLabel: 'قبل ٣٠ م',
    distanceLabel: '٢ كم',
  ),
  TaskEntity(
    id: 'WQF-2024-013',
    title: 'مركز الأوقاف - الرصافة',
    location: 'بغداد - الرصافة',
    status: TaskStatus.pending,
    timeLabel: 'قبل ٥٠ م',
    distanceLabel: '٣.٢ كم',
  ),
  TaskEntity(
    id: 'WQF-2024-021',
    title: 'مستودع الأنبار - إعادة',
    location: 'الرمادي',
    status: TaskStatus.returned,
    timeLabel: 'أمس ٠٥:٠٠ م',
    distanceLabel: '١٦٢ كم',
    rejectionReason: 'سبب الرفض: عدم إعادة التشخيص',
  ),
];
