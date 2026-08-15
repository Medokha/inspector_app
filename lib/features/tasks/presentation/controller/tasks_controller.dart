import 'package:flutter/foundation.dart';
import 'package:inspector_app/core/field/offline_queue_store.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_tasks_usecase.dart';

class TasksController extends ChangeNotifier {
  TasksController({required GetTasksUseCase getTasks}) : _getTasks = getTasks;

  final GetTasksUseCase _getTasks;

  List<TaskEntity> _tasks = <TaskEntity>[];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  bool _fromOfflineCache = false;
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _error;

  TaskStatus? _statusFilter;

  List<TaskEntity> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;
  bool get fromOfflineCache => _fromOfflineCache;
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
    _fromOfflineCache = false;
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
      // حفظ محلي لعرض المهام دون اتصال
      if (_statusFilter == null) {
        await OfflineQueueStore.cacheTasksJson(
          _tasks.map((t) => t.toJson()).toList(),
        );
      }
    } catch (e) {
      final cached = await OfflineQueueStore.loadCachedTasks();
      if (cached.isNotEmpty) {
        _tasks = cached.map(TaskEntity.fromJson).toList();
        if (_statusFilter != null) {
          _tasks = _tasks.where((t) => t.status == _statusFilter).toList();
        }
        _fromOfflineCache = true;
        _hasMore = false;
        _error = null;
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isMoreLoading || !_hasMore || _fromOfflineCache) return;

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
