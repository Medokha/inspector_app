import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/tasks/data/services/inspector_tracking_service.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:inspector_app/features/tasks/domain/usecases/start_task_usecase.dart';

class TaskDetailsController extends ChangeNotifier {
  TaskDetailsController({
    required GetTaskDetailsUseCase getTaskDetails,
    required StartTaskUseCase startTask,
    required InspectorTrackingService tracking,
  })  : _getTaskDetails = getTaskDetails,
        _startTask = startTask,
        _tracking = tracking;

  final GetTaskDetailsUseCase _getTaskDetails;
  final StartTaskUseCase _startTask;
  final InspectorTrackingService _tracking;

  TaskDetailsEntity? _details;
  bool _isLoading = false;
  bool _isStarting = false;
  String? _error;

  TaskDetailsEntity? get details => _details;
  bool get isLoading => _isLoading;
  bool get isStarting => _isStarting;
  String? get error => _error;

  Future<void> load(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _details = await _getTaskDetails(id);
      if (_details?.task.status == TaskStatus.inProgress) {
        await _tracking.start(id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> start(String id) async {
    _isStarting = true;
    _error = null;
    notifyListeners();
    try {
      final position = await _tracking.currentPosition();
      await _startTask(
        id,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      await _tracking.start(id);
      _details = await _getTaskDetails(id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }
}
