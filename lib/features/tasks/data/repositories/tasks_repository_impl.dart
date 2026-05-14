import 'package:inspector_app/features/tasks/data/datasources/tasks_remote_data_source.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_step_entity.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._remote);

  final TasksRemoteDataSource _remote;

  @override
  Future<List<TaskEntity>> getTasks({
    String? date,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _remote.getTasks(
      date: date,
      status: status,
      page: page,
      pageSize: pageSize,
    );

    final List<dynamic> items = response['items'] ?? [];
    return items.map((json) {
      final dueDate = DateTime.tryParse(json['dueDate']?.toString() ?? '');
      return TaskEntity(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        location: json['locationName']?.toString() ?? json['governorate']?.toString() ?? '',
        status: _parseStatus(json['status']?.toString()),
        timeLabel: _formatDueDate(dueDate),
        distanceLabel: '', // TODO: Calculate distance if coordinates available
        rejectionReason: json['rejectionReason']?.toString(),
      );
    }).toList();
  }

  @override
  Future<TaskDetailsEntity> getTaskDetails(String id) async {
    final json = await _remote.getTaskDetails(id);
    final dueDate = DateTime.tryParse(json['dueDate']?.toString() ?? '');
    
    final task = TaskEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['locationName']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      timeLabel: _formatDueDate(dueDate),
      distanceLabel: '',
      rejectionReason: json['rejectionReason']?.toString(),
    );

    return TaskDetailsEntity(
      task: task,
      code: task.id.split('-').last.toUpperCase(),
      plannedDate: _formatFullDate(dueDate),
      stageLabel: _getStageLabel(task.status),
      steps: _getStepsForStatus(task.status),
      mapHint: 'اضغط لفتح الخريطة',
      inspectorNote: json['reportNotes']?.toString() ?? '',
    );
  }

  TaskStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'rejected':
        return TaskStatus.returned;
      case 'delayed':
        return TaskStatus.delayed;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return 'متأخرة';
    if (diff.inDays == 0) return 'اليوم ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    return 'بعد ${diff.inDays} يوم';
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStageLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress: return 'جارية';
      case TaskStatus.completed: return 'منتهية';
      case TaskStatus.returned: return 'مُعادة';
      case TaskStatus.pending: return 'معلقة';
      default: return '';
    }
  }

  List<TaskStepEntity> _getStepsForStatus(TaskStatus status) {
    // Basic logic to map task status to steps for UI
    return [
      TaskStepEntity(
        title: 'بيانات الموقع',
        status: status == TaskStatus.pending ? TaskStepStatus.pending : TaskStepStatus.done,
        timeLabel: status == TaskStatus.pending ? '' : 'تم التحقق',
      ),
      TaskStepEntity(
        title: 'تفقد الموقع',
        status: status == TaskStatus.inProgress ? TaskStepStatus.inProgress : (status == TaskStatus.completed ? TaskStepStatus.done : TaskStepStatus.pending),
        timeLabel: status == TaskStatus.inProgress ? 'جارية' : '',
      ),
      TaskStepEntity(
        title: 'رفع التقرير',
        status: status == TaskStatus.completed ? TaskStepStatus.done : TaskStepStatus.pending,
        timeLabel: status == TaskStatus.completed ? 'تم الإرسال' : '',
      ),
    ];
  }
}
