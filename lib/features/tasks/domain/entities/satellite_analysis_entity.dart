class SatelliteAnalysisEntity {
  const SatelliteAnalysisEntity({
    required this.id,
    required this.taskId,
    required this.summaryAr,
    required this.riskLevel,
    required this.attentionScore,
    required this.analysisEngine,
    required this.analyzedAt,
    this.changeScore = 0,
    this.snapshotUrl,
    this.previousSnapshotUrl,
    this.fieldConsistencyNote,
    this.imageryProvider,
    this.findings = const <String>[],
    this.recommendations = const <String>[],
    this.tags = const <String>[],
    this.latitude,
    this.longitude,
  });

  final String id;
  final String taskId;
  final String summaryAr;
  final String riskLevel;
  final int attentionScore;
  final int changeScore;
  final String analysisEngine;
  final DateTime analyzedAt;
  final String? snapshotUrl;
  final String? previousSnapshotUrl;
  final String? fieldConsistencyNote;
  final String? imageryProvider;
  final List<String> findings;
  final List<String> recommendations;
  final List<String> tags;
  final double? latitude;
  final double? longitude;

  String get riskLabelAr {
    switch (riskLevel) {
      case 'Critical':
        return 'حرج';
      case 'High':
        return 'مرتفع';
      case 'Medium':
        return 'متوسط';
      default:
        return 'منخفض';
    }
  }

  factory SatelliteAnalysisEntity.fromJson(Map<String, dynamic> json) {
    List<String> asList(dynamic v) {
      if (v is! List) return const <String>[];
      return v.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }

    double? asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '');
    }

    return SatelliteAnalysisEntity(
      id: json['id']?.toString() ?? '',
      taskId: json['taskId']?.toString() ?? '',
      summaryAr: json['summaryAr']?.toString() ?? '',
      riskLevel: json['riskLevel']?.toString() ?? 'Low',
      attentionScore: (json['attentionScore'] as num?)?.toInt() ?? 0,
      changeScore: (json['changeScore'] as num?)?.toInt() ?? 0,
      analysisEngine: json['analysisEngine']?.toString() ?? '',
      analyzedAt: DateTime.tryParse(json['analyzedAt']?.toString() ?? '') ?? DateTime.now(),
      snapshotUrl: json['snapshotUrl']?.toString(),
      previousSnapshotUrl: json['previousSnapshotUrl']?.toString(),
      fieldConsistencyNote: json['fieldConsistencyNote']?.toString(),
      imageryProvider: json['imageryProvider']?.toString(),
      findings: asList(json['findings']),
      recommendations: asList(json['recommendations']),
      tags: asList(json['tags']),
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
    );
  }

  SatelliteAnalysisEntity withAbsoluteUrls(String baseUrl) {
    String? abs(String? path) {
      if (path == null || path.isEmpty) return path;
      if (path.startsWith('http')) return path;
      return '$baseUrl${path.startsWith('/') ? path : '/$path'}';
    }

    return SatelliteAnalysisEntity(
      id: id,
      taskId: taskId,
      summaryAr: summaryAr,
      riskLevel: riskLevel,
      attentionScore: attentionScore,
      changeScore: changeScore,
      analysisEngine: analysisEngine,
      analyzedAt: analyzedAt,
      snapshotUrl: abs(snapshotUrl),
      previousSnapshotUrl: abs(previousSnapshotUrl),
      fieldConsistencyNote: fieldConsistencyNote,
      imageryProvider: imageryProvider,
      findings: findings,
      recommendations: recommendations,
      tags: tags,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
