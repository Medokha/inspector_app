import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';

abstract class TasksRepository {
  Future<List<TaskEntity>> getTasks({
    String? date,
    String? status,
    int page = 1,
    int pageSize = 10,
  });
  Future<TaskDetailsEntity> getTaskDetails(String id);
}
