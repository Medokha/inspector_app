import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_task_details_usecase.dart';

class TaskDetailsController extends ChangeNotifier {
  TaskDetailsController({required GetTaskDetailsUseCase getTaskDetails})
      : _getTaskDetails = getTaskDetails;

  final GetTaskDetailsUseCase _getTaskDetails;

  TaskDetailsEntity? _details;
  bool _isLoading = false;
  String? _error;

  TaskDetailsEntity? get details => _details;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _details = await _getTaskDetails(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
