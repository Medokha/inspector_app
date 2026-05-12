import 'package:inspector_app/features/profile/domain/entities/inspector_profile.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_metric.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_stats.dart';
import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';
import 'package:inspector_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<ProfileOverview> getProfileOverview() async {
    return const ProfileOverview(
      profile: InspectorProfile(
        name: 'أحمد النجفي',
        email: 'inspector@waqf.iq',
        region: 'مفتش ميداني - مديرية الوقف السني',
        initials: 'أخ',
        tags: <String>['بغداد', 'البصرة', 'نينوى'],
      ),
      stats: PerformanceStats(
        completed: 28,
        pending: 32,
        rejected: 3,
        late: 1,
      ),
      metrics: <PerformanceMetric>[
        PerformanceMetric(label: 'الانضباط', value: 78),
        PerformanceMetric(label: 'الالتزام', value: 82),
        PerformanceMetric(label: 'الجودة', value: 79),
      ],
      recentReports: <ReportItem>[
        ReportItem(title: 'مسجد الرحمن', status: ReportStatus.accepted, dateLabel: '٤ أيار ٢٠٢٦'),
        ReportItem(title: 'مستودع الأنبار', status: ReportStatus.rejected, dateLabel: '٤ أيار ٢٠٢٦'),
        ReportItem(title: 'مدرسة الكاظمية', status: ReportStatus.accepted, dateLabel: '٣ أيار ٢٠٢٦'),
      ],
    );
  }
}
