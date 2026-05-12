import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/domain/usecases/get_route_stops_usecase.dart';

class RouteController extends ChangeNotifier {
  RouteController({required GetRouteStopsUseCase getStops}) : _getStops = getStops;

  final GetRouteStopsUseCase _getStops;

  List<RouteStopEntity> _stops = const <RouteStopEntity>[];
  bool _isLoading = false;
  String? _error;

  List<RouteStopEntity> get stops => _stops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stops = await _getStops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
