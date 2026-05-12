import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';

abstract class RouteRepository {
  Future<List<RouteStopEntity>> getRouteStops();
}
