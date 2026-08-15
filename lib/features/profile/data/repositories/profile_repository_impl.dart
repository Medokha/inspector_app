import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/api_mappers.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_session.dart';
import 'package:inspector_app/features/profile/domain/entities/inspector_profile.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_metric.dart';
import 'package:inspector_app/features/profile/domain/entities/performance_stats.dart';
import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';
import 'package:inspector_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api, this._session);

  final ApiClient _api;
  final AuthSession _session;

  @override
  Future<ProfileOverview> getProfileOverview() async {
    final profileJson = JsonMap.map(await _api.get('/api/Inspectors/me'));
    final statsJson = JsonMap.map(await _api.get('/api/Inspectors/me/stats'));
    final reportsRaw = await _api.get('/api/Inspectors/me/reports');
    final reports = reportsRaw is List ? JsonMap.mapList(reportsRaw) : JsonMap.mapList(JsonMap.map(reportsRaw)['items']);

    final name = JsonMap.str(profileJson['fullName'], _session.name ?? 'مفتش');
    final email = JsonMap.str(profileJson['email'], _session.email ?? '');
    final tags = JsonMap.mapList(profileJson['governorates'])
        .map((item) => JsonMap.str(item['name']))
        .where((item) => item.isNotEmpty)
        .toList();
    final region = JsonMap.str(profileJson['region']).isNotEmpty
        ? JsonMap.str(profileJson['region'])
        : (tags.isEmpty ? 'مفتش ميداني' : tags.join(' - '));

    await _session.save(name: name, email: email, inspectorId: JsonMap.str(profileJson['id']));

    final completed = (statsJson['completed'] as num?)?.toInt() ?? 0;
    final approved = (statsJson['approved'] as num?)?.toInt() ?? 0;
    final pending = (statsJson['pending'] as num?)?.toInt() ?? 0;
    final rejected = (statsJson['rejected'] as num?)?.toInt() ?? 0;
    final delayed = (statsJson['delayed'] as num?)?.toInt() ?? 0;
    final total = (statsJson['total'] as num?)?.toInt() ?? (completed + pending + rejected);

    int percent(num value, num max) {
      if (max <= 0) return 0;
      return ((value / max) * 100).round().clamp(0, 100);
    }

    return ProfileOverview(
      profile: InspectorProfile(
        name: name,
        email: email,
        region: region,
        initials: ApiMappers.initials(name),
        tags: tags,
      ),
      stats: PerformanceStats(
        completed: completed + approved,
        pending: pending,
        rejected: rejected,
        late: delayed,
      ),
      metrics: <PerformanceMetric>[
        PerformanceMetric(label: 'الانضباط', value: percent(completed + approved, total)),
        PerformanceMetric(label: 'الالتزام', value: percent(total - delayed, total)),
        PerformanceMetric(label: 'الجودة', value: percent(approved, approved + rejected)),
      ],
      recentReports: reports.take(5).map((item) {
        final status = JsonMap.str(item['status']).toLowerCase();
        return ReportItem(
          id: JsonMap.str(item['id']),
          title: JsonMap.str(item['title'], 'تقرير'),
          status: status == 'approved' || status == 'accepted'
              ? ReportStatus.accepted
              : status == 'rejected'
                  ? ReportStatus.rejected
                  : ReportStatus.pending,
          dateLabel: ApiMappers.dateLabel(item['date']),
        );
      }).toList(),
    );
  }

  @override
  Future<List<ReportItem>> getReports() async {
    final reportsRaw = await _api.get('/api/Inspectors/me/reports');
    final reports = reportsRaw is List
        ? JsonMap.mapList(reportsRaw)
        : JsonMap.mapList(JsonMap.map(reportsRaw)['items']);

    return reports.map((item) {
      final status = JsonMap.str(item['status']).toLowerCase();
      return ReportItem(
        id: JsonMap.str(item['id']),
        title: JsonMap.str(item['title'], 'تقرير'),
        status: status == 'approved' || status == 'accepted'
            ? ReportStatus.accepted
            : status == 'rejected'
                ? ReportStatus.rejected
                : ReportStatus.pending,
        dateLabel: ApiMappers.dateLabel(item['date'] ?? item['completedAt'] ?? item['createdAt']),
      );
    }).toList();
  }
}
