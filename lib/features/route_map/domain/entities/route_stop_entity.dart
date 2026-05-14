enum RouteStopStatus {
  inProgress,
  pending,
  completed,
}

class RouteStopEntity {
  const RouteStopEntity({
    required this.taskId,
    required this.order,
    required this.title,
    required this.status,
    required this.timeLabel,
    required this.distanceLabel,
    this.latitude,
    this.longitude,
  });

  final String taskId;
  final int order;
  final String title;
  final RouteStopStatus status;
  final String timeLabel;
  final String distanceLabel;
  final double? latitude;
  final double? longitude;
}
