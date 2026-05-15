import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';

abstract class ProfileRepository {
  Future<ProfileOverview> getProfileOverview();
  Future<List<ReportItem>> getReports();
}
