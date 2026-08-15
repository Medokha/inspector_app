import 'package:flutter/foundation.dart';
import 'package:inspector_app/core/field/geo_utils.dart';
import 'package:inspector_app/core/notifications/inspector_realtime_service.dart';

/// تنبيه عند الاقتراب من موقع المهمة.
class ProximityAlertService {
  ProximityAlertService({this.approachRadiusMeters = 200});

  final double approachRadiusMeters;
  final Set<String> _alertedTaskIds = <String>{};

  /// يُستدعى مع كل تحديث موقع أثناء التتبع أو قبل البدء.
  Future<bool> checkAndNotify({
    required String taskId,
    required String taskTitle,
    required double currentLat,
    required double currentLng,
    required double? siteLat,
    required double? siteLng,
  }) async {
    if (siteLat == null || siteLng == null) return false;
    if (_alertedTaskIds.contains(taskId)) return false;

    final distance = GeoUtils.distanceMeters(
      lat1: currentLat,
      lng1: currentLng,
      lat2: siteLat,
      lng2: siteLng,
    );

    if (distance > approachRadiusMeters) return false;

    _alertedTaskIds.add(taskId);
    try {
      await showInspectorLocalNotification(
        title: 'اقتربت من موقع المهمة',
        body: '$taskTitle — على بعد ${distance.round()} م',
        taskId: taskId,
        notificationId: 'prox_$taskId',
      );
      return true;
    } catch (e) {
      debugPrint('ProximityAlert failed: $e');
      return false;
    }
  }

  void reset(String taskId) => _alertedTaskIds.remove(taskId);

  void resetAll() => _alertedTaskIds.clear();
}
