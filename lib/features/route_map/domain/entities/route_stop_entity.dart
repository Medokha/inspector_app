enum RouteStopStatus {
  inProgress,
  pending,
  completed,
}

class RouteStopEntity {
  const RouteStopEntity({
    required this.order,
    required this.title,
    required this.status,
    required this.timeLabel,
    required this.distanceLabel,
    this.taskId,
    this.latitude,
    this.longitude,
  });

  final int order;
  final String title;
  final RouteStopStatus status;
  final String timeLabel;
  final String distanceLabel;
  final String? taskId;
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;
}
