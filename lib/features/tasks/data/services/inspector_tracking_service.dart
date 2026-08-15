import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class InspectorTrackingService {
  InspectorTrackingService(this._repository);

  final TasksRepository _repository;
  Timer? _timer;
  String? _taskId;

  String? get activeTaskId => _taskId;

  Future<Position?> currentPosition() async {
    final permission = await _ensurePermission();
    if (!permission) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> start(String taskId) async {
    _taskId = taskId;
    await _send();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _send());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _taskId = null;
  }

  Future<bool> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _send() async {
    final taskId = _taskId;
    if (taskId == null) return;
    try {
      final position = await currentPosition();
      if (position == null) return;
      await _repository.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        taskId: taskId,
      );
    } catch (_) {}
  }
}
