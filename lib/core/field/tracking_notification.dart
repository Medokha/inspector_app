import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// إشعار دائم أثناء التتبع بالخلفية: «جاري التتبع».
class TrackingNotification {
  TrackingNotification._();

  static const channelId = 'inspector_tracking';
  static const notificationId = 71001;

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> ensureReady() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: DarwinInitializationSettings(),
      ),
    );
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        'تتبع الميدان',
        description: 'إشعار مستمر أثناء تسجيل مسار المهمة',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );
    _ready = true;
  }

  static Future<void> showOngoing({required String taskTitle}) async {
    await ensureReady();
    await _plugin.show(
      notificationId,
      'جاري التتبع',
      taskTitle.isEmpty ? 'تسجيل مسار المهمة قيد التشغيل' : 'تسجيل مسار: $taskTitle',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'تتبع الميدان',
          channelDescription: 'إشعار مستمر أثناء تسجيل مسار المهمة',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          playSound: false,
          enableVibration: false,
          category: AndroidNotificationCategory.service,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentSound: false,
          presentBadge: false,
        ),
      ),
    );
  }

  static Future<void> hide() async {
    await ensureReady();
    await _plugin.cancel(notificationId);
  }
}
