import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<void> call(String id) => _repository.markAsRead(id);
}

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<void> call() => _repository.markAllAsRead();
}
