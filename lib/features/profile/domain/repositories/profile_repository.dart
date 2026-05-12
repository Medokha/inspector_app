import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';

abstract class ProfileRepository {
  Future<ProfileOverview> getProfileOverview();
}
