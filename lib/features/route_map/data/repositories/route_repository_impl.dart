import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  @override
  Future<List<RouteStopEntity>> getRouteStops() async {
    return const <RouteStopEntity>[
      RouteStopEntity(
        order: 1,
        title: 'مسجد الرحمن - الكرخ',
        status: RouteStopStatus.inProgress,
        timeLabel: '١٠:٠٠ ص',
        distanceLabel: '٢ كم',
      ),
      RouteStopEntity(
        order: 2,
        title: 'مركز الأوقاف - الرصافة',
        status: RouteStopStatus.pending,
        timeLabel: '١٢:٠٠ م',
        distanceLabel: '٣.٢ كم',
      ),
      RouteStopEntity(
        order: 3,
        title: 'مدرسة الوقف - الكاظمية',
        status: RouteStopStatus.pending,
        timeLabel: '٠٣:٠٠ م',
        distanceLabel: '٤.٣ كم',
      ),
    ];
  }
}
