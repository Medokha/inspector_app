import 'package:inspector_app/core/security/audit_trail_presenter.dart';

import 'task_entity.dart';
import 'task_status.dart';
import 'task_step_entity.dart';

class TaskPhotoEntity {
  const TaskPhotoEntity({
    required this.id,
    required this.url,
    this.description,
    this.fileName,
  });

  final String id;
  final String url;
  final String? description;
  final String? fileName;

  bool get isPdf {
    final name = (fileName ?? '').toLowerCase();
    final path = url.toLowerCase();
    return name.endsWith('.pdf') || path.endsWith('.pdf') || path.contains('.pdf?');
  }
}

class TaskReportEntity {
  const TaskReportEntity({
    required this.generalCondition,
    required this.qualityScore,
    required this.hasViolations,
    this.reportNotes,
    this.rejectionReason,
    this.photos = const <TaskPhotoEntity>[],
  });

  final String generalCondition;
  final int qualityScore;
  final bool hasViolations;
  final String? reportNotes;
  final String? rejectionReason;
  final List<TaskPhotoEntity> photos;
}

class TaskDetailsEntity {
  const TaskDetailsEntity({
    required this.task,
    required this.code,
    required this.plannedDate,
    required this.stageLabel,
    required this.steps,
    this.mapHint,
    this.inspectorNote,
    this.description,
    this.latitude,
    this.longitude,
    this.report,
    this.auditTrail = const <AuditTrailEntry>[],
  });

  final TaskEntity task;
  final String code;
  final String plannedDate;
  final String stageLabel;
  final List<TaskStepEntity> steps;
  final String? mapHint;
  final String? inspectorNote;
  final String? description;
  final double? latitude;
  final double? longitude;
  final TaskReportEntity? report;
  final List<AuditTrailEntry> auditTrail;

  bool get hasLocation => latitude != null && longitude != null;

  bool get hasReport => report != null;

  bool get canStart =>
      task.status == TaskStatus.pending || task.status == TaskStatus.returned;

  bool get canSubmitReport =>
      task.status == TaskStatus.inProgress || task.status == TaskStatus.returned;

  bool get isTracking => task.status == TaskStatus.inProgress;

  bool get isOverdue {
    final due = task.dueDate;
    if (due == null) return false;
    return due.toLocal().isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed;
  }

  String get remainingLabel {
    final due = task.dueDate;
    if (due == null) return 'غير محدد';
    final diff = due.toLocal().difference(DateTime.now());
    if (diff.isNegative) {
      final late = diff.abs();
      if (late.inHours < 1) return 'متأخر ${late.inMinutes} د';
      if (late.inHours < 24) return 'متأخر ${late.inHours} س';
      return 'متأخر ${late.inDays} يوم';
    }
    if (diff.inHours < 1) return '${diff.inMinutes} د';
    if (diff.inHours < 24) return '${diff.inHours} ساعة';
    return '${diff.inDays} يوم';
  }
}
