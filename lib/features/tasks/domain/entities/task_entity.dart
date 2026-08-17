import 'task_status.dart';

class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    required this.timeLabel,
    this.distanceLabel,
    this.rejectionReason,
    this.description,
    this.latitude,
    this.longitude,
    this.dueDate,
    this.satelliteRiskLevel,
  });

  final String id;
  final String title;
  final String location;
  final TaskStatus status;
  final String timeLabel;
  final String? distanceLabel;
  final String? rejectionReason;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime? dueDate;
  final String? satelliteRiskLevel;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'location': location,
        'status': status.name,
        'timeLabel': timeLabel,
        'distanceLabel': distanceLabel,
        'rejectionReason': rejectionReason,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'dueDate': dueDate?.toIso8601String(),
        'satelliteRiskLevel': satelliteRiskLevel,
      };

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    TaskStatus status;
    try {
      status = TaskStatus.values.firstWhere((s) => s.name == json['status']);
    } catch (_) {
      status = TaskStatus.pending;
    }
    return TaskEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: status,
      timeLabel: json['timeLabel']?.toString() ?? '',
      distanceLabel: json['distanceLabel']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      description: json['description']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
      satelliteRiskLevel: json['satelliteRiskLevel']?.toString(),
    );
  }
}
