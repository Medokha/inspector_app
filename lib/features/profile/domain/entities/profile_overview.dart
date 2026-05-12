import 'package:inspector_app/features/profile/domain/entities/inspector_profile.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_metric.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_stats.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';

class ProfileOverview {
  const ProfileOverview({
    required this.profile,
    required this.stats,
    required this.metrics,
    required this.recentReports,
  });

  final InspectorProfile profile;
  final PerformanceStats stats;
  final List<PerformanceMetric> metrics;
  final List<ReportItem> recentReports;
}
