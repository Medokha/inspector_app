import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inspector_app/core/config/api_config.dart';
import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/notifications/inspector_firebase_options.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_session.dart';
import 'package:signalr_netcore/signalr_client.dart';

class InspectorIncomingNotification {
  const InspectorIncomingNotification({
    required this.title,
    required this.body,
    this.taskId,
    this.notificationId,
  });

  final String title;
  final String body;
  final String? taskId;
  final String? notificationId;
}

@pragma('vm:entry-point')
Future<void> inspectorFirebaseBackgroundHandler(RemoteMessage message) async {
  await _ensureInspectorFirebase();
}

Future<FirebaseApp?> _ensureInspectorFirebase() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }
  } catch (_) {}

  try {
    return await Firebase.initializeApp(
      options: InspectorFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    try {
      if (Firebase.apps.isNotEmpty) {
        return Firebase.app();
      }
      return await Firebase.initializeApp();
    } catch (_) {
      return null;
    }
  }
}

class InspectorRealtimeService {
  InspectorRealtimeService(this._api, this._session);

  static const _hubPath = '/hubs/inspector-notifications';
  static const _androidChannelId = 'inspector_alerts';

  final ApiClient _api;
  final AuthSession _session;
  final _local = FlutterLocalNotificationsPlugin();
  final _incoming = StreamController<InspectorIncomingNotification>.broadcast();
  final ValueNotifier<int> unreadBadge = ValueNotifier<int>(0);

  HubConnection? _hub;
  String? _fcmToken;
  Timer? _unreadDebounce;

  Stream<InspectorIncomingNotification> get incoming => _incoming.stream;

  Future<void> start() async {
    if (!_session.isAuthenticated) return;
    await _initLocalNotifications();
    await _startFirebase();
    await _connectHub();
    await refreshUnreadBadge();
  }

  Future<void> stop() async {
    _unreadDebounce?.cancel();
    _unreadDebounce = null;
    unreadBadge.value = 0;
    try {
      if (_fcmToken != null) {
        await _api.post('/api/Auth/fcm-token/unregister', body: <String, String>{
          'fcmToken': _fcmToken!,
        });
      }
    } catch (_) {}
    try {
      await _api.post('/api/Auth/logout');
    } catch (_) {}
    try {
      await _hub?.stop();
    } catch (_) {}
    _hub = null;
  }

  void setUnreadBadge(int count) {
    unreadBadge.value = count < 0 ? 0 : count;
  }

  Future<void> refreshUnreadBadge() async {
    if (!_session.isAuthenticated) {
      unreadBadge.value = 0;
      return;
    }
    try {
      final json = await _api.get('/api/Notifications/me');
      if (json is Map) {
        final count = json['unreadCount'];
        if (count is num) {
          unreadBadge.value = count.toInt();
          return;
        }
        final items = json['items'];
        if (items is List) {
          unreadBadge.value = items.where((item) {
            if (item is! Map) return false;
            return item['isRead'] != true;
          }).length;
          return;
        }
      }
      if (json is List) {
        unreadBadge.value = json.where((item) {
          if (item is! Map) return false;
          return item['isRead'] != true;
        }).length;
      }
    } catch (_) {}
  }

  void _publishIncoming(InspectorIncomingNotification notification) {
    _incoming.add(notification);
    // تحديث فوري للرقم ثم مزامنة من السيرفر بعد لحظة قصيرة
    unreadBadge.value = unreadBadge.value + 1;
    _unreadDebounce?.cancel();
    _unreadDebounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(refreshUnreadBadge());
    });
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        _incoming.add(InspectorIncomingNotification(title: '', body: '', taskId: payload));
      },
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        'تنبيهات المفتش',
        description: 'إشعارات مهام التفتيش والتقارير',
        importance: Importance.high,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _startFirebase() async {
    try {
      final app = await _ensureInspectorFirebase();
      if (app == null) return;
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      _fcmToken = await messaging.getToken();
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        await _api.post('/api/Auth/fcm-token', body: <String, String>{
          'fcmToken': _fcmToken!,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        });
      }

      messaging.onTokenRefresh.listen((token) async {
        _fcmToken = token;
        if (!_session.isAuthenticated) return;
        await _api.post('/api/Auth/fcm-token', body: <String, String>{
          'fcmToken': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        });
      });

      FirebaseMessaging.onMessage.listen(_onRemoteMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onRemoteMessage);
    } catch (_) {}
  }

  void _onRemoteMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final taskId = message.data['taskId'];
    final notificationId = message.data['notificationId'];
    _publishIncoming(InspectorIncomingNotification(
      title: title,
      body: body,
      taskId: taskId,
      notificationId: notificationId,
    ));
    unawaited(_showLocal(title, body, taskId));
  }

  Future<void> _connectHub() async {
    final token = _session.token;
    if (token == null || token.isEmpty) return;

    try {
      await _hub?.stop();
    } catch (_) {}

    final hub = HubConnectionBuilder()
        .withUrl(
          '${ApiConfig.baseUrl}$_hubPath',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            requestTimeout: 15000,
          ),
        )
        .withAutomaticReconnect()
        .build();

    hub.on('notificationReceived', (args) {
      if (args == null || args.isEmpty) return;
      final payload = args.first;
      if (payload is! Map) return;
      final map = Map<String, dynamic>.from(payload);
      final data = map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : <String, dynamic>{};
      final title = (map['title'] ?? 'إشعار جديد').toString();
      final body = (map['body'] ?? '').toString();
      final taskId = data['taskId']?.toString();
      _publishIncoming(InspectorIncomingNotification(
        title: title,
        body: body,
        taskId: taskId,
        notificationId: data['notificationId']?.toString(),
      ));
      unawaited(_showLocal(title, body, taskId));
    });

    try {
      await hub.start();
      _hub = hub;
    } catch (_) {
      _hub = null;
    }
  }

  Future<void> _showLocal(String title, String body, String? taskId) async {
    if (title.isEmpty && body.isEmpty) return;
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          'تنبيهات المفتش',
          channelDescription: 'إشعارات مهام التفتيش والتقارير',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: taskId,
    );
  }
}
