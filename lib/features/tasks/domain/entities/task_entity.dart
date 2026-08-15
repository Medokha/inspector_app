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
}
