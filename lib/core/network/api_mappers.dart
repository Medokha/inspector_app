import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';

class JsonMap {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> mapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.map(map).toList();
  }

  static String str(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static double? asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }
}

class ApiMappers {
  static TaskStatus taskStatus(dynamic raw) {
    switch (raw?.toString().toLowerCase().replaceAll('-', '_')) {
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'rejected':
      case 'returned':
        return TaskStatus.returned;
      case 'completed':
      case 'approved':
        return TaskStatus.completed;
      case 'delayed':
        return TaskStatus.delayed;
      default:
        return TaskStatus.pending;
    }
  }

  static NotificationType notificationType(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'report':
        return NotificationType.report;
      case 'task':
        return NotificationType.task;
      default:
        return NotificationType.general;
    }
  }

  static RouteStopStatus routeStatus(dynamic raw) {
    switch (taskStatus(raw)) {
      case TaskStatus.inProgress:
        return RouteStopStatus.inProgress;
      case TaskStatus.completed:
        return RouteStopStatus.completed;
      default:
        return RouteStopStatus.pending;
    }
  }

  static TaskEntity task(Map<String, dynamic> json) {
    final location = JsonMap.str(json['locationName']).isNotEmpty
        ? JsonMap.str(json['locationName'])
        : JsonMap.str(json['governorate'], '—');
    final rejection = JsonMap.str(json['rejectionReason']);
    return TaskEntity(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title'], 'مهمة'),
      location: location,
      status: taskStatus(json['status']),
      timeLabel: relativeTime(json['dueDate']),
      rejectionReason: rejection.isEmpty ? null : rejection,
      description: JsonMap.str(json['description']).isEmpty ? null : JsonMap.str(json['description']),
      latitude: JsonMap.asDouble(json['latitude']),
      longitude: JsonMap.asDouble(json['longitude']),
      dueDate: parseDate(json['dueDate']),
      satelliteRiskLevel: JsonMap.str(json['satelliteRiskLevel']).isEmpty
          ? null
          : JsonMap.str(json['satelliteRiskLevel']),
    );
  }

  static NotificationItemEntity notification(Map<String, dynamic> json) {
    final title = JsonMap.str(json['title']);
    final body = JsonMap.str(json['body']);
    return NotificationItemEntity(
      id: JsonMap.str(json['id']),
      title: body.isEmpty ? title : (title.isEmpty ? body : '$title - $body'),
      timeLabel: relativeTime(json['createdAt']),
      type: notificationType(json['type']),
      isUnread: json['isRead'] != true,
      taskId: JsonMap.str(json['taskId']).isEmpty ? null : JsonMap.str(json['taskId']),
    );
  }

  static String relativeTime(dynamic raw) {
    final date = parseDate(raw);
    if (date == null) return '';
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String dateLabel(dynamic raw) {
    final date = parseDate(raw);
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  static DateTime? parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'م';
    String first(String value) => String.fromCharCodes(value.runes.take(1));
    if (parts.length == 1) return first(parts.first);
    return '${first(parts.first)}${first(parts.last)}';
  }
}
