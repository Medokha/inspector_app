import 'package:inspector_app/features/home/domain/entities/home_overview.dart';
import 'package:inspector_app/features/home/domain/repositories/home_repository.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeOverview> getOverview() async {
    final active = _tasks;
    final returned = _tasks.where((item) => item.status == TaskStatus.returned).toList();
    final unread = _notifications.where((item) => item.isUnread).length;

    return HomeOverview(
      inspectorName: 'أحمد النجفي',
      region: 'بغداد - الكرخ',
      totalToday: 4,
      returnedCount: returned.length,
      activeTasks: active,
      recentNotifications: _notifications.take(2).toList(),
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

final List<NotificationItemEntity> _notifications = <NotificationItemEntity>[
  NotificationItemEntity(
    id: 'n1',
    title: 'تم رفض تقرير مستودع الأنبار - الصور غير واضحة برجاء إعادة الزيارة',
    timeLabel: 'منذ ساعتين',
    type: NotificationType.report,
    isUnread: true,
  ),
  NotificationItemEntity(
    id: 'n2',
    title: 'مهمة جديدة لمركز الأوقاف - الرصافة، الموعد اليوم ٢:٠٠ م',
    timeLabel: 'منذ ٣ س',
    type: NotificationType.task,
    isUnread: true,
  ),
];
