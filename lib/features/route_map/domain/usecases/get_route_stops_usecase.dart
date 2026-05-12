import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/domain/repositories/route_repository.dart';

class GetRouteStopsUseCase {
  const GetRouteStopsUseCase(this._repository);

  final RouteRepository _repository;

  Future<List<RouteStopEntity>> call() {
    return _repository.getRouteStops();
  }
}
