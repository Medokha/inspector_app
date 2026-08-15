import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inspector_app/core/field/field_sync_service.dart';
import 'package:inspector_app/core/field/geo_utils.dart';
import 'package:inspector_app/core/field/offline_queue_store.dart';
import 'package:inspector_app/core/field/proximity_alert_service.dart';
import 'package:inspector_app/core/field/tracking_notification.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

/// يسجّل مسار حركة المفتش (مع دعم عدم الاتصال + إشعار دائم + تنبيه اقتراب).
class InspectorTrackingService {
  InspectorTrackingService(
    this._repository, {
    FieldSyncService? sync,
    ProximityAlertService? proximity,
  })  : _sync = sync,
        _proximity = proximity ?? ProximityAlertService();

  final TasksRepository _repository;
  final FieldSyncService? _sync;
  final ProximityAlertService _proximity;

  Timer? _heartbeat;
  StreamSubscription<Position>? _positionSub;
  String? _taskId;
  String _taskTitle = '';
  double? _siteLat;
  double? _siteLng;
  double? _lastLat;
  double? _lastLng;
  bool _sending = false;

  static const double minDistanceMeters = 12;

  String? get activeTaskId => _taskId;
  bool get isTracking => _taskId != null;

  Future<Position?> currentPosition() async {
    final permission = await _ensurePermission();
    if (!permission) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// [siteLat]/[siteLng] لتنبيه الاقتراب من موقع المهمة.
  Future<void> start(
    String taskId, {
    String? taskTitle,
    double? siteLat,
    double? siteLng,
  }) async {
    if (taskId.isEmpty) return;

    final sameTask = _taskId == taskId;
    _taskId = taskId;
    _taskTitle = taskTitle ?? _taskTitle;
    _siteLat = siteLat ?? _siteLat;
    _siteLng = siteLng ?? _siteLng;
    if (!sameTask) {
      _lastLat = null;
      _lastLng = null;
      _proximity.reset(taskId);
    }

    await TrackingNotification.showOngoing(taskTitle: _taskTitle);
    await _send(force: true);

    await _positionSub?.cancel();
    final LocationSettings settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            intervalDuration: const Duration(seconds: 15),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'جاري التتبع',
              notificationText: 'تسجيل مسار المهمة قيد التشغيل',
              enableWakeLock: true,
            ),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (position) => unawaited(_send(position: position)),
      onError: (Object e) {
        debugPrint('InspectorTracking stream error: $e');
        unawaited(_restartSimpleStream());
      },
    );

    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_send());
    });
  }

  Future<void> _restartSimpleStream() async {
    await _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) => unawaited(_send(position: position)));
  }

  Future<void> stop() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    await _positionSub?.cancel();
    _positionSub = null;
    _taskId = null;
    _taskTitle = '';
    _siteLat = null;
    _siteLng = null;
    _lastLat = null;
    _lastLng = null;
    await TrackingNotification.hide();
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

  Future<void> _send({Position? position, bool force = false}) async {
    final taskId = _taskId;
    if (taskId == null || _sending) return;
    _sending = true;
    try {
      final permission = await _ensurePermission();
      if (!permission) return;

      final pos = position ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );

      if (!force && _lastLat != null && _lastLng != null) {
        final meters = GeoUtils.distanceMeters(
          lat1: _lastLat!,
          lng1: _lastLng!,
          lat2: pos.latitude,
          lng2: pos.longitude,
        );
        if (meters < minDistanceMeters) return;
      }

      await _proximity.checkAndNotify(
        taskId: taskId,
        taskTitle: _taskTitle,
        currentLat: pos.latitude,
        currentLng: pos.longitude,
        siteLat: _siteLat,
        siteLng: _siteLng,
      );

      final sync = _sync;
      final online = sync == null ? true : await sync.isOnline;
      if (!online) {
        await OfflineQueueStore.enqueueRoutePoint(
          taskId: taskId,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        await sync.refreshPendingCount();
      } else {
        try {
          await _repository.updateLocation(
            latitude: pos.latitude,
            longitude: pos.longitude,
            taskId: taskId,
          );
        } catch (e) {
          debugPrint('InspectorTracking upload failed, queueing: $e');
          await OfflineQueueStore.enqueueRoutePoint(
            taskId: taskId,
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
          await sync?.refreshPendingCount();
        }
      }

      _lastLat = pos.latitude;
      _lastLng = pos.longitude;
    } catch (e) {
      debugPrint('InspectorTracking send failed: $e');
    } finally {
      _sending = false;
    }
  }
}
