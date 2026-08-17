import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inspector_app/core/field/geofence_service.dart';
import 'package:inspector_app/core/field/task_start_proximity_monitor.dart';
import 'package:inspector_app/features/tasks/data/services/inspector_tracking_service.dart';
import 'package:inspector_app/features/tasks/domain/entities/satellite_analysis_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:inspector_app/features/tasks/domain/usecases/start_task_usecase.dart';

class TaskDetailsController extends ChangeNotifier {
  TaskDetailsController({
    required GetTaskDetailsUseCase getTaskDetails,
    required StartTaskUseCase startTask,
    required InspectorTrackingService tracking,
    required TasksRepository tasksRepository,
    GeofenceService? geofence,
    TaskStartProximityMonitor? proximityMonitor,
  })  : _getTaskDetails = getTaskDetails,
        _startTask = startTask,
        _tracking = tracking,
        _tasksRepository = tasksRepository,
        _geofence = geofence ?? GeofenceService(),
        _proximityMonitor = proximityMonitor ??
            TaskStartProximityMonitor(
              radiusMeters: (geofence ?? GeofenceService()).defaultRadiusMeters,
            );

  final GetTaskDetailsUseCase _getTaskDetails;
  final StartTaskUseCase _startTask;
  final InspectorTrackingService _tracking;
  final TasksRepository _tasksRepository;
  final GeofenceService _geofence;
  final TaskStartProximityMonitor _proximityMonitor;

  TaskDetailsEntity? _details;
  List<SatelliteAnalysisEntity> _satelliteHistory = const <SatelliteAnalysisEntity>[];
  bool _isLoading = false;
  bool _isStarting = false;
  bool _isAnalyzing = false;
  String? _error;
  double? _distanceToSiteMeters;
  bool _isWithinStartRadius = false;
  bool _showStartPrompt = false;
  bool _proximityWatching = false;

  TaskDetailsEntity? get details => _details;
  List<SatelliteAnalysisEntity> get satelliteHistory => _satelliteHistory;
  bool get isLoading => _isLoading;
  bool get isStarting => _isStarting;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  double? get distanceToSiteMeters => _distanceToSiteMeters;
  bool get isWithinStartRadius => _isWithinStartRadius;
  bool get showStartPrompt => _showStartPrompt;
  double get startRadiusMeters => _geofence.defaultRadiusMeters;

  @override
  void dispose() {
    unawaited(stopStartProximityWatch());
    super.dispose();
  }

  Future<void> load(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _details = await _getTaskDetails(id);
      try {
        _satelliteHistory = await _tasksRepository.getSatelliteHistory(id);
      } catch (_) {
        _satelliteHistory = _details?.satelliteAnalysis == null
            ? const <SatelliteAnalysisEntity>[]
            : <SatelliteAnalysisEntity>[_details!.satelliteAnalysis!];
      }
      if (_details?.task.status == TaskStatus.inProgress) {
        await _tracking.start(
          id,
          taskTitle: _details?.task.title,
          siteLat: _details?.latitude,
          siteLng: _details?.longitude,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إن لم يوجد تحليل والموقع متوفر — يشغّل تحليلاً أولياً تلقائياً.
  Future<void> ensureSatelliteAnalysis(String id) async {
    final d = _details;
    if (d == null || !d.hasLocation || d.satelliteAnalysis != null || _isAnalyzing) return;
    await runSatelliteAnalysis(id);
  }

  Future<SatelliteAnalysisEntity?> runSatelliteAnalysis(
    String id, {
    List<int>? snapshotBytes,
  }) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();
    try {
      final analysis = await _tasksRepository.runSatelliteAnalysis(
        id,
        forceRefresh: true,
        snapshotBytes: snapshotBytes,
      );
      if (_details != null) {
        _details = TaskDetailsEntity(
          task: _details!.task,
          code: _details!.code,
          plannedDate: _details!.plannedDate,
          stageLabel: _details!.stageLabel,
          steps: _details!.steps,
          mapHint: _details!.mapHint,
          inspectorNote: _details!.inspectorNote,
          description: _details!.description,
          latitude: _details!.latitude,
          longitude: _details!.longitude,
          report: _details!.report,
          auditTrail: _details!.auditTrail,
          satelliteAnalysis: analysis,
        );
      }
      try {
        _satelliteHistory = await _tasksRepository.getSatelliteHistory(id);
      } catch (_) {
        _satelliteHistory = <SatelliteAnalysisEntity>[analysis];
      }
      return analysis;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<bool> start(String id) async {
    _isStarting = true;
    _error = null;
    notifyListeners();
    try {
      final position = await _tracking.currentPosition();
      if (position == null) {
        _error = 'تعذر الحصول على موقعك. فعّل خدمة الموقع وحاول مجدداً';
        return false;
      }

      final details = _details ?? await _getTaskDetails(id);
      final gate = _geofence.canStartTask(
        currentLat: position.latitude,
        currentLng: position.longitude,
        siteLat: details.latitude,
        siteLng: details.longitude,
      );
      if (!gate.allowed) {
        _error = gate.message ?? 'أنت خارج نطاق موقع المهمة';
        return false;
      }

      await _startTask(
        id,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _tracking.start(
        id,
        taskTitle: details.task.title,
        siteLat: details.latitude,
        siteLng: details.longitude,
      );
      _details = await _getTaskDetails(id);
      await stopStartProximityWatch();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  /// يراقب المسافة قبل البدء ويُطلق نافذة عند دخول نطاق 200 م.
  Future<void> beginStartProximityWatch() async {
    final details = _details;
    if (_proximityWatching || details == null || !details.canStart || !details.hasLocation) {
      return;
    }

    _proximityWatching = true;
    await _proximityMonitor.start(
      siteLat: details.latitude!,
      siteLng: details.longitude!,
      onUpdate: (distance, within) {
        _distanceToSiteMeters = distance;
        _isWithinStartRadius = within;
        notifyListeners();
      },
      onEnterRadius: (distance) {
        _distanceToSiteMeters = distance;
        _isWithinStartRadius = true;
        _showStartPrompt = true;
        notifyListeners();
      },
    );
  }

  Future<void> stopStartProximityWatch() async {
    _proximityWatching = false;
    _showStartPrompt = false;
    await _proximityMonitor.stop();
  }

  void clearStartPrompt() {
    if (!_showStartPrompt) return;
    _showStartPrompt = false;
    notifyListeners();
  }
}
