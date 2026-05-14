import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/domain/repositories/route_repository.dart';
import 'package:inspector_app/features/tasks/data/datasources/tasks_remote_data_source.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(this._remote);

  final TasksRemoteDataSource _remote;

  @override
  Future<List<RouteStopEntity>> getRouteStops() async {
    final response = await _remote.getRoute(date: 'today');
    final List<dynamic> waypoints = response['waypoints'] ?? [];

    return waypoints.map((json) {
      return RouteStopEntity(
        taskId: json['taskId']?.toString() ?? '',
        order: json['visitOrder'] as int? ?? 0,
        title: json['title']?.toString() ?? '',
        status: _parseStatus(json['status']?.toString()),
        timeLabel: '', // TODO: Get from API if available
        distanceLabel: '', // TODO: Calculate
        latitude: (json['lat'] as num?)?.toDouble(),
        longitude: (json['lng'] as num?)?.toDouble(),
      );
    }).toList();
  }

  RouteStopStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return RouteStopStatus.inProgress;
      case 'completed':
        return RouteStopStatus.completed;
      case 'pending':
      default:
        return RouteStopStatus.pending;
    }
  }
}
