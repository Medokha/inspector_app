import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_tasks_usecase.dart';

class TasksController extends ChangeNotifier {
  TasksController({required GetTasksUseCase getTasks}) : _getTasks = getTasks;

  final GetTasksUseCase _getTasks;

  List<TaskEntity> _tasks = const <TaskEntity>[];
  bool _isLoading = false;
  String? _error;

  List<TaskEntity> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _getTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
