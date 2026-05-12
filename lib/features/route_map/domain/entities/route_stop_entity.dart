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
  });

  final int order;
  final String title;
  final RouteStopStatus status;
  final String timeLabel;
  final String distanceLabel;
}
