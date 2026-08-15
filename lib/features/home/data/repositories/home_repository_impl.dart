import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/api_mappers.dart';
import 'package:inspector_app/features/home/domain/entities/home_overview.dart';
import 'package:inspector_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<HomeOverview> getOverview() async {
    final json = JsonMap.map(await _api.get('/api/Inspectors/me/home'));
    return HomeOverview(
      inspectorName: JsonMap.str(json['inspectorName'], 'مفتش'),
      region: JsonMap.str(json['region'], 'مفتش ميداني'),
      totalToday: (json['totalToday'] as num?)?.toInt() ?? 0,
      returnedCount: (json['returnedCount'] as num?)?.toInt() ?? 0,
      activeTasks: JsonMap.mapList(json['activeTasks']).map(ApiMappers.task).toList(),
      recentNotifications: JsonMap.mapList(json['recentNotifications']).map(ApiMappers.notification).toList(),
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
    );
  }
}
