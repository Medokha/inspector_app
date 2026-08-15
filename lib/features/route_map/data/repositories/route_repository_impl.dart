import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/api_mappers.dart';
import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<RouteStopEntity>> getRouteStops() async {
    final json = JsonMap.map(await _api.get('/api/Tasks/route', query: <String, String>{'date': 'today'}));
    final waypoints = JsonMap.mapList(json['waypoints']);
    return waypoints.map((item) {
      final due = ApiMappers.parseDate(item['dueDate']);
      final timeLabel = due == null
          ? ''
          : '${due.toLocal().hour.toString().padLeft(2, '0')}:${due.toLocal().minute.toString().padLeft(2, '0')}';
      return RouteStopEntity(
        order: (item['visitOrder'] as num?)?.toInt() ?? 0,
        title: JsonMap.str(item['title'], JsonMap.str(item['locationName'], 'موقع')),
        status: ApiMappers.routeStatus(item['status']),
        timeLabel: timeLabel,
        distanceLabel: JsonMap.str(item['locationName']),
        taskId: JsonMap.str(item['taskId']).isEmpty ? null : JsonMap.str(item['taskId']),
        latitude: JsonMap.asDouble(item['lat'] ?? item['latitude']),
        longitude: JsonMap.asDouble(item['lng'] ?? item['longitude']),
      );
    }).toList();
  }
}
