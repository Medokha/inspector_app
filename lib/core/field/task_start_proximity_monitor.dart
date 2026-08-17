import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inspector_app/core/field/geo_utils.dart';

/// يراقب موقع المفتش قبل بدء المهمة ويُبلّغ عند دخول نطاق 200 م.
class TaskStartProximityMonitor {
  TaskStartProximityMonitor({
    this.radiusMeters = 200,
    this.exitHysteresisMeters = 250,
  });

  final double radiusMeters;
  final double exitHysteresisMeters;

  StreamSubscription<Position>? _sub;
  bool _inside = false;
  bool _promptShownForEntry = false;

  Future<void> start({
    required double siteLat,
    required double siteLng,
    required void Function(double distanceMeters, bool withinRadius) onUpdate,
    required void Function(double distanceMeters) onEnterRadius,
  }) async {
    await stop();

    final permission = await _ensurePermission();
    if (!permission) return;

    void handlePosition(double lat, double lng) {
      final distance = GeoUtils.distanceMeters(
        lat1: lat,
        lng1: lng,
        lat2: siteLat,
        lng2: siteLng,
      );
      final within = distance <= radiusMeters;
      onUpdate(distance, within);

      if (within && !_inside) {
        _inside = true;
        if (!_promptShownForEntry) {
          _promptShownForEntry = true;
          onEnterRadius(distance);
        }
      } else if (distance > exitHysteresisMeters) {
        _inside = false;
        _promptShownForEntry = false;
      }
    }

    try {
      final initial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      handlePosition(initial.latitude, initial.longitude);
    } catch (e) {
      debugPrint('TaskStartProximity initial position failed: $e');
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    ).listen(
      (position) => handlePosition(position.latitude, position.longitude),
      onError: (Object e) => debugPrint('TaskStartProximity stream error: $e'),
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _inside = false;
    _promptShownForEntry = false;
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
}
