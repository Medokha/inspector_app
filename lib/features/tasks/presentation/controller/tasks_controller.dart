import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_tasks_usecase.dart';

import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';

class TasksController extends ChangeNotifier {
  TasksController({required GetTasksUseCase getTasks}) : _getTasks = getTasks;

  final GetTasksUseCase _getTasks;

  List<TaskEntity> _tasks = <TaskEntity>[];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _error;
  
  TaskStatus? _statusFilter;

  List<TaskEntity> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  TaskStatus? get statusFilter => _statusFilter;

  void setFilter(TaskStatus? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      _tasks = await _getTasks(
        status: _statusMap[_statusFilter],
        page: _currentPage,
        pageSize: _pageSize,
      );
      if (_tasks.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isMoreLoading || !_hasMore) return;

    _isMoreLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newItems = await _getTasks(
        status: _statusMap[_statusFilter],
        page: nextPage,
        pageSize: _pageSize,
      );
      
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _tasks.addAll(newItems);
        _currentPage = nextPage;
        if (newItems.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  static const Map<TaskStatus, String> _statusMap = {
    TaskStatus.pending: 'pending',
    TaskStatus.inProgress: 'in_progress',
    TaskStatus.completed: 'completed',
    TaskStatus.returned: 'rejected',
    TaskStatus.delayed: 'delayed',
  };
}
