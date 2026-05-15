import 'package:inspector_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:inspector_app/features/profile/domain/entities/inspector_profile.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_metric.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_stats.dart';
import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';
import 'package:inspector_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<ProfileOverview> getProfileOverview() async {
    final profileJson = await _remote.getProfile();
    final statsJson = await _remote.getStats();

    final List<dynamic> govList = profileJson['governorates'] ?? [];
    final governorates = govList.map((g) => g['name']?.toString() ?? '').toList();

    final profile = InspectorProfile(
      name: profileJson['fullName']?.toString() ?? '',
      email: profileJson['email']?.toString() ?? '',
      region: governorates.isNotEmpty ? governorates.join('، ') : 'غير محدد',
      initials: _getInitials(profileJson['fullName']?.toString() ?? ''),
      tags: governorates,
    );

    final stats = PerformanceStats(
      completed: statsJson['completed'] as int? ?? 0,
      pending: statsJson['pending'] as int? ?? 0,
      rejected: statsJson['rejected'] as int? ?? 0,
      late: statsJson['delayed'] as int? ?? 0,
    );

    // Calculate metrics based on stats
    final total = statsJson['totalTasks'] as int? ?? 1;
    final completionRate = ((stats.completed / total) * 100).toInt();
    final qualityRate = 85; // Placeholder or calculate if available
    final punctualityRate = 90; // Placeholder

    final reportsJson = await _remote.getReports();
    final List<ReportItem> recentReports = reportsJson.take(3).map<ReportItem>((json) {
      return ReportItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        status: _parseReportStatus(json['status']?.toString()),
        dateLabel: _formatDate(json['date']?.toString()),
      );
    }).toList();

    return ProfileOverview(
      profile: profile,
      stats: stats,
      metrics: [
        PerformanceMetric(label: 'معدل الإنجاز', value: completionRate),
        PerformanceMetric(label: 'جودة التقارير', value: qualityRate),
        PerformanceMetric(label: 'الانضباط بالمواعيد', value: punctualityRate),
      ],
      recentReports: recentReports,
    );
  }

  @override
  Future<List<ReportItem>> getReports() async {
    final reportsJson = await _remote.getReports();
    return reportsJson.map<ReportItem>((json) {
      return ReportItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        status: _parseReportStatus(json['status']?.toString()),
        dateLabel: _formatDate(json['date']?.toString()),
      );
    }).toList();
  }

  ReportStatus _parseReportStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'approved':
        return ReportStatus.accepted;
      case 'rejected':
        return ReportStatus.rejected;
      case 'pending':
      default:
        return ReportStatus.pending;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
