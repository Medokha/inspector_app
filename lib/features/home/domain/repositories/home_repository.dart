import 'package:inspector_app/features/home/domain/entities/home_overview.dart';

abstract class HomeRepository {
  Future<HomeOverview> getOverview();
}
