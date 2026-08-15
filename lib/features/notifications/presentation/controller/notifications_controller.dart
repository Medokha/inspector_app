import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inspector_app/core/notifications/inspector_realtime_service.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_unread_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required GetNotificationsUseCase getNotifications,
    required GetUnreadNotificationsUseCase getUnreadCount,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required InspectorRealtimeService realtime,
  })  : _getNotifications = getNotifications,
        _getUnreadCount = getUnreadCount,
        _markRead = markRead,
        _markAllRead = markAllRead,
        _realtime = realtime;

  final GetNotificationsUseCase _getNotifications;
  final GetUnreadNotificationsUseCase _getUnreadCount;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final InspectorRealtimeService _realtime;

  List<NotificationItemEntity> _items = const <NotificationItemEntity>[];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _timer;
  StreamSubscription<InspectorIncomingNotification>? _sub;

  List<NotificationItemEntity> get items => _items;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _getNotifications();
      final unread = await _getUnreadCount();
      _items = items;
      _unreadCount = unread;
      _realtime.setUnreadBadge(unread);
    } catch (_) {
      _items = const <NotificationItemEntity>[];
      _unreadCount = 0;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    try {
      await _markRead(id);
      _items = _items
          .map((item) => item.id == id ? item.copyWith(isUnread: false) : item)
          .toList();
      _unreadCount = _items.where((item) => item.isUnread).length;
      _realtime.setUnreadBadge(_unreadCount);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _markAllRead();
      _items = _items.map((item) => item.copyWith(isUnread: false)).toList();
      _unreadCount = 0;
      _realtime.setUnreadBadge(0);
      notifyListeners();
    } catch (_) {}
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => load());
    _sub?.cancel();
    _sub = _realtime.incoming.listen((_) => load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}
