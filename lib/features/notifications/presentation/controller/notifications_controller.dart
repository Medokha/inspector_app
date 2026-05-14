import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_unread_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

import 'package:inspector_app/core/notifications/notification_service.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required GetNotificationsUseCase getNotifications,
    required GetUnreadNotificationsUseCase getUnreadCount,
    required NotificationsRepository repository,
  })  : _getNotifications = getNotifications,
        _getUnreadCount = getUnreadCount,
        _repository = repository;

  final GetNotificationsUseCase _getNotifications;
  final GetUnreadNotificationsUseCase _getUnreadCount;
  final NotificationsRepository _repository;

  List<NotificationItemEntity> _items = const <NotificationItemEntity>[];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _timer;
  StreamSubscription? _notificationSubscription;

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

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await load();
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => load());
  }

  void startListeningToNotifications() {
    _notificationSubscription?.cancel();
    _notificationSubscription = NotificationService().onNotificationReceived.listen((_) {
      load();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
