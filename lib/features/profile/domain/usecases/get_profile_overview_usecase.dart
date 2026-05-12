import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';
import 'package:inspector_app/features/profile/domain/repositories/profile_repository.dart';

class GetProfileOverviewUseCase {
  const GetProfileOverviewUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileOverview> call() {
    return _repository.getProfileOverview();
  }
}
