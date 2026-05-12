import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  @override
  Future<List<NotificationItemEntity>> getNotifications() async {
    return _notifications;
  }

  @override
  Future<int> getUnreadCount() async {
    return _notifications.where((item) => item.isUnread).length;
  }
}

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
  NotificationItemEntity(
    id: 'n3',
    title: 'تذكير: مهمة قاربت على الانتهاء لمسجد الرحمن خلال ساعتين',
    timeLabel: 'منذ ٥ س',
    type: NotificationType.general,
    isUnread: false,
  ),
  NotificationItemEntity(
    id: 'n4',
    title: 'تم اعتماد تقرير مدرسة الكاظمية من المدير',
    timeLabel: 'أمس',
    type: NotificationType.report,
    isUnread: false,
  ),
];
