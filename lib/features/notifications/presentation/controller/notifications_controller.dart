import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_unread_notifications_usecase.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required GetNotificationsUseCase getNotifications,
    required GetUnreadNotificationsUseCase getUnreadCount,
  })  : _getNotifications = getNotifications,
        _getUnreadCount = getUnreadCount;

  final GetNotificationsUseCase _getNotifications;
  final GetUnreadNotificationsUseCase _getUnreadCount;

  List<NotificationItemEntity> _items = const <NotificationItemEntity>[];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _timer;

  List<NotificationItemEntity> get items => _items;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final items = await _getNotifications();
    final unread = await _getUnreadCount();

    _items = items;
    _unreadCount = unread;
    _isLoading = false;
    notifyListeners();
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
