import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TasksRepository _repository;

  Future<List<TaskEntity>> call() {
    return _repository.getTasks();
  }
}
