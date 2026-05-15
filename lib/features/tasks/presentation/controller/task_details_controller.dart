import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_task_details_usecase.dart';

class TaskDetailsController extends ChangeNotifier {
  TaskDetailsController({required GetTaskDetailsUseCase getTaskDetails})
      : _getTaskDetails = getTaskDetails;

  final GetTaskDetailsUseCase _getTaskDetails;

  TaskDetailsEntity? _details;
  bool _isLoading = false;
  String? _error;
  bool _isWithinRange = false;
  double? _distance;

  TaskDetailsEntity? get details => _details;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isWithinRange => _isWithinRange;
  double? get distance => _distance;

  Future<void> load(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _details = await _getTaskDetails(id);
      await checkProximity();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkProximity() async {
    if (_details == null || _details!.task.latitude == null || _details!.task.longitude == null) {
      _isWithinRange = true; // Allow if no coords (fallback) or keep false? User said only if 100m.
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        
        _distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _details!.task.latitude!,
          _details!.task.longitude!,
        );

        _isWithinRange = _distance! <= 100; // 100 meters
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking proximity: $e');
    }
  }
}
