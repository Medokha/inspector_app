import 'package:inspector_app/features/notifications/domain/repositories/notifications_repository.dart';

class GetUnreadNotificationsUseCase {
  const GetUnreadNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<int> call() {
    return _repository.getUnreadCount();
  }
}
