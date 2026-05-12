import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class GetTaskDetailsUseCase {
  const GetTaskDetailsUseCase(this._repository);

  final TasksRepository _repository;

  Future<TaskDetailsEntity> call(String id) {
    return _repository.getTaskDetails(id);
  }
}
