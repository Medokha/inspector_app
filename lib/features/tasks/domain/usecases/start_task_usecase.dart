import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class StartTaskUseCase {
  const StartTaskUseCase(this._repository);

  final TasksRepository _repository;

  Future<void> call(String id, {double? latitude, double? longitude}) {
    return _repository.startTask(id, latitude: latitude, longitude: longitude);
  }
}
