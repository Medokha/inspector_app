import 'package:inspector_app/features/home/domain/entities/home_overview.dart';
import 'package:inspector_app/features/home/domain/repositories/home_repository.dart';

class GetHomeOverviewUseCase {
  const GetHomeOverviewUseCase(this._repository);

  final HomeRepository _repository;

  Future<HomeOverview> call() {
    return _repository.getOverview();
  }
}
