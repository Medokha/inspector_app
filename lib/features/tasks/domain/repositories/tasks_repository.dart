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
  Future<void> startTask(String id, {double? latitude, double? longitude});
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? taskId,
  });
  Future<void> submitReport({
    required String taskId,
    required String generalCondition,
    required int qualityScore,
    required bool hasViolations,
    String? reportNotes,
    List<String> photoPaths = const <String>[],
    List<({List<int> bytes, String filename})> photoFiles =
        const <({List<int> bytes, String filename})>[],
  });
}
