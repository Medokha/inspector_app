import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inspector_app/core/config/api_config.dart';
import 'package:inspector_app/core/navigation/notification_navigation.dart';
import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/notifications/inspector_firebase_options.dart';
import 'package:inspector_app/core/notifications/notification_prefs.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_session.dart';
import 'package:signalr_netcore/signalr_client.dart';

class InspectorIncomingNotification {
  const InspectorIncomingNotification({
    required this.title,
    required this.body,
    this.taskId,
    this.notificationId,
    this.category,
  });

  final String title;
  final String body;
  final String? taskId;
  final String? notificationId;
  final String? category;
}

const _androidChannelId = 'inspector_alerts';
const _androidChannelName = 'تنبيهات المفتش';
const _androidChannelDesc = 'إشعارات مهام التفتيش والتقارير';

@pragma('vm:entry-point')
Future<void> inspectorFirebaseBackgroundHandler(RemoteMessage message) async {
  await ensureInspectorFirebase();
  final category = _categoryFromData(message.data);
  if (!await NotificationPrefs.allowsCategory(category)) return;

  // إشعار خارجي موثوق عند الإغلاق/الخلفية في كل الأحوال
  final title = message.notification?.title ?? message.data['title'] ?? 'إشعار جديد';
  final body = message.notification?.body ?? message.data['body'] ?? '';
  final taskId = message.data['taskId'];
  await showInspectorLocalNotification(
    title: title.toString(),
    body: body.toString(),
    taskId: taskId?.toString(),
    notificationId: message.data['notificationId']?.toString(),
  );
}

Future<FirebaseApp?> ensureInspectorFirebase() async {
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

String? _categoryFromData(Map<String, dynamic> data) {
  final raw = data['category'] ?? data['type'] ?? data['notificationType'];
  if (raw == null) return null;
  final value = raw.toString().trim().toLowerCase();
  if (value == 'inspector_notification') return null;
  return value;
}

final FlutterLocalNotificationsPlugin _sharedLocal = FlutterLocalNotificationsPlugin();
bool _localReady = false;
final Set<String> _shownIds = <String>{};

Future<void> ensureInspectorNotificationChannel() async {
  if (!_localReady) {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _sharedLocal.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        final action = response.actionId;
        final effective = (action == 'start') ? '$payload|start' : payload;
        NotificationNavigation.handlePayload(effective);
      },
    );
    _localReady = true;
  }

  final androidPlugin =
      _sharedLocal.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    ),
  );
  await androidPlugin?.requestNotificationsPermission();
}

Future<void> showInspectorLocalNotification({
  required String title,
  required String body,
  String? taskId,
  String? notificationId,
}) async {
  if (title.trim().isEmpty && body.trim().isEmpty) return;

  final dedupeKey = notificationId ?? '$title|$body|$taskId';
  if (_shownIds.contains(dedupeKey)) return;
  _shownIds.add(dedupeKey);
  if (_shownIds.length > 80) {
    _shownIds.remove(_shownIds.first);
  }

  await ensureInspectorNotificationChannel();

  final id = notificationId == null
      ? DateTime.now().millisecondsSinceEpoch.remainder(100000)
      : notificationId.hashCode.abs().remainder(100000);

    await _sharedLocal.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        actions: taskId == null || taskId.isEmpty
            ? null
            : <AndroidNotificationAction>[
                const AndroidNotificationAction('open', 'فتح المهمة'),
                const AndroidNotificationAction('start', 'بدء التتبع'),
              ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: taskId,
  );
}

class InspectorRealtimeService {
  InspectorRealtimeService(this._api, this._session);

  static const _hubPath = '/hubs/inspector-notifications';

  final ApiClient _api;
  final AuthSession _session;
  final _incoming = StreamController<InspectorIncomingNotification>.broadcast();
  final ValueNotifier<int> unreadBadge = ValueNotifier<int>(0);

  HubConnection? _hub;
  String? _fcmToken;
  Timer? _unreadDebounce;
  bool _started = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _tokenSub;

  Stream<InspectorIncomingNotification> get incoming => _incoming.stream;

  Future<void> start() async {
    if (!_session.isAuthenticated) return;
    if (_started) {
      await refreshUnreadBadge();
      return;
    }
    _started = true;

    await ensureInspectorNotificationChannel();
    await _startFirebase();
    await _connectHub();
    await refreshUnreadBadge();
  }

  Future<void> stop() async {
    _started = false;
    _unreadDebounce?.cancel();
    _unreadDebounce = null;
    unreadBadge.value = 0;
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _tokenSub?.cancel();
    _onMessageSub = null;
    _onOpenedSub = null;
    _tokenSub = null;

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
    unreadBadge.value = unreadBadge.value + 1;
    _unreadDebounce?.cancel();
    _unreadDebounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(refreshUnreadBadge());
    });
  }

  Future<void> _startFirebase() async {
    try {
      final app = await ensureInspectorFirebase();
      if (app == null) return;
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _registerToken(await messaging.getToken());

      await _tokenSub?.cancel();
      _tokenSub = messaging.onTokenRefresh.listen((token) {
        unawaited(_registerToken(token));
      });

      await _onMessageSub?.cancel();
      _onMessageSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      await _onOpenedSub?.cancel();
      _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedMessage);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _onOpenedMessage(initial);
      }
    } catch (_) {}
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) return;
    _fcmToken = token;
    if (!_session.isAuthenticated) return;
    try {
      await _api.post('/api/Auth/fcm-token', body: <String, String>{
        'fcmToken': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      });
    } catch (_) {}
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final category = _categoryFromData(message.data);
    if (!await NotificationPrefs.allowsCategory(category)) return;

    final title = message.notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final taskId = message.data['taskId']?.toString();
    final notificationId = message.data['notificationId']?.toString();

    _publishIncoming(InspectorIncomingNotification(
      title: title.toString(),
      body: body.toString(),
      taskId: taskId,
      notificationId: notificationId,
      category: category,
    ));
    // في الواجهة الأمامية النظام لا يعرض الإشعار — نعرضه محلياً خارج التطبيق.
    await showInspectorLocalNotification(
      title: title.toString(),
      body: body.toString(),
      taskId: taskId,
      notificationId: notificationId,
    );
  }

  void _onOpenedMessage(RemoteMessage message) {
    final category = _categoryFromData(message.data);
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final taskId = message.data['taskId']?.toString();
    final action = message.data['action']?.toString().toLowerCase();
    _incoming.add(InspectorIncomingNotification(
      title: title.toString(),
      body: body.toString(),
      taskId: taskId,
      notificationId: message.data['notificationId']?.toString(),
      category: category,
    ));
    if (taskId != null && taskId.isNotEmpty) {
      final payload = (action == 'start') ? '$taskId|start' : taskId;
      NotificationNavigation.handlePayload(payload);
    }
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
      final data = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : <String, dynamic>{};
      // قد تأتي الحقول في الجذر أو داخل data
      final merged = <String, dynamic>{...data, ...map};
      final category = _categoryFromData(merged);
      final title = (map['title'] ?? 'إشعار جديد').toString();
      final body = (map['body'] ?? '').toString();
      final taskId = (data['taskId'] ?? map['taskId'])?.toString();
      final notificationId = (data['notificationId'] ?? map['notificationId'])?.toString();

      unawaited(() async {
        if (!await NotificationPrefs.allowsCategory(category)) return;
        _publishIncoming(InspectorIncomingNotification(
          title: title,
          body: body,
          taskId: taskId,
          notificationId: notificationId,
          category: category,
        ));
        await showInspectorLocalNotification(
          title: title,
          body: body,
          taskId: taskId,
          notificationId: notificationId,
        );
      }());
    });

    try {
      await hub.start();
      _hub = hub;
    } catch (_) {
      _hub = null;
    }
  }
}
