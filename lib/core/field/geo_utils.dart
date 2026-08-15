import 'dart:math' as math;

/// أدوات مسافات جغرافية مشتركة للتشغيل الميداني.
class GeoUtils {
  GeoUtils._();

  static const double earthRadiusMeters = 6371000;

  static double degreesToRadians(double deg) => deg * math.pi / 180.0;

  /// المسافة بين نقطتين بالمتر (Haversine).
  static double distanceMeters({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final dLat = degreesToRadians(lat2 - lat1);
    final dLng = degreesToRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(degreesToRadians(lat1)) *
            math.cos(degreesToRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * earthRadiusMeters * math.asin(math.sqrt(a));
  }

  /// هل النقطة داخل نطاق نصف القطر بالمتر؟
  static bool isWithinRadius({
    required double currentLat,
    required double currentLng,
    required double targetLat,
    required double targetLng,
    required double radiusMeters,
  }) {
    return distanceMeters(
          lat1: currentLat,
          lng1: currentLng,
          lat2: targetLat,
          lng2: targetLng,
        ) <=
        radiusMeters;
  }
}
