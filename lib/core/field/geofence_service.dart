import 'package:inspector_app/core/field/geo_utils.dart';

/// نتيجة التحقق من الحضور الجغرافي قبل بدء المهمة.
class GeofenceCheckResult {
  const GeofenceCheckResult({
    required this.allowed,
    required this.distanceMeters,
    required this.requiredRadiusMeters,
    this.message,
  });

  final bool allowed;
  final double distanceMeters;
  final double requiredRadiusMeters;
  final String? message;

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} م';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} كم';
  }
}

/// تحقق حضور أقوى: لا يُسمح ببدء المهمة إلا ضمن نطاق محدد.
class GeofenceService {
  GeofenceService({this.defaultRadiusMeters = 200});

  /// نصف قطر الحضور الافتراضي بالمتر.
  final double defaultRadiusMeters;

  /// يتحقق أن المفتش داخل نطاق موقع المهمة.
  GeofenceCheckResult canStartTask({
    required double currentLat,
    required double currentLng,
    required double? siteLat,
    required double? siteLng,
    double? radiusMeters,
  }) {
    final radius = radiusMeters ?? defaultRadiusMeters;

    if (siteLat == null || siteLng == null) {
      // لا إحداثيات للمهمة → نسمح بالبدء مع تنبيه
      return GeofenceCheckResult(
        allowed: true,
        distanceMeters: 0,
        requiredRadiusMeters: radius,
        message: 'لا توجد إحداثيات للمهمة — تم السماح بالبدء',
      );
    }

    final distance = GeoUtils.distanceMeters(
      lat1: currentLat,
      lng1: currentLng,
      lat2: siteLat,
      lng2: siteLng,
    );

    if (distance <= radius) {
      return GeofenceCheckResult(
        allowed: true,
        distanceMeters: distance,
        requiredRadiusMeters: radius,
        message: 'أنت ضمن نطاق الموقع (${distance.round()} م)',
      );
    }

    return GeofenceCheckResult(
      allowed: false,
      distanceMeters: distance,
      requiredRadiusMeters: radius,
      message:
          'يجب أن تكون ضمن $radius م من موقع المهمة. موقعك الحالي يبعد ${distance.round()} م',
    );
  }
}
