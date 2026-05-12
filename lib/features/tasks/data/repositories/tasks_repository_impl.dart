import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_step_entity.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  @override
  Future<List<TaskEntity>> getTasks() async {
    return _tasks;
  }

  @override
  Future<TaskDetailsEntity> getTaskDetails(String id) async {
    final task = _tasks.firstWhere((item) => item.id == id, orElse: () => _tasks.first);
    return _details[id] ?? _details.values.first.copyWith(task: task);
  }
}

final List<TaskEntity> _tasks = <TaskEntity>[
  TaskEntity(
    id: 'WQF-2024-007',
    title: 'مسجد الرحمن - الكرخ',
    location: 'بغداد - الكرخ',
    status: TaskStatus.inProgress,
    timeLabel: 'قبل ٣٠ م',
    distanceLabel: '٢ كم',
  ),
  TaskEntity(
    id: 'WQF-2024-013',
    title: 'مركز الأوقاف - الرصافة',
    location: 'بغداد - الرصافة',
    status: TaskStatus.pending,
    timeLabel: 'قبل ٥٠ م',
    distanceLabel: '٣.٢ كم',
  ),
  TaskEntity(
    id: 'WQF-2024-021',
    title: 'مستودع الأنبار - إعادة',
    location: 'الرمادي',
    status: TaskStatus.returned,
    timeLabel: 'أمس ٠٥:٠٠ م',
    distanceLabel: '١٦٢ كم',
    rejectionReason: 'سبب الرفض: عدم إعادة التشخيص',
  ),
  TaskEntity(
    id: 'WQF-2024-022',
    title: 'مدرسة الوقف - الكاظمية',
    location: 'بغداد - الكاظمية',
    status: TaskStatus.pending,
    timeLabel: 'اليوم ٠٣:٠٠ م',
    distanceLabel: '٤.٣ كم',
  ),
];

final Map<String, TaskDetailsEntity> _details = <String, TaskDetailsEntity>{
  'WQF-2024-007': TaskDetailsEntity(
    task: _tasks.first,
    code: 'WQF-2024-007',
    plannedDate: 'السبت ٤ أيار - ٩:٠٠ ص',
    stageLabel: 'جارية',
    steps: const <TaskStepEntity>[
      TaskStepEntity(title: 'بيانات الموقع', status: TaskStepStatus.done, timeLabel: 'تم إدخالها'),
      TaskStepEntity(title: 'تفقد الموقع', status: TaskStepStatus.inProgress, timeLabel: 'جارية'),
      TaskStepEntity(title: 'رفع التقرير', status: TaskStepStatus.pending, timeLabel: 'معلقة'),
    ],
    mapHint: 'اضغط لفتح الخريطة',
    inspectorNote: 'تم الإبلاغ عن عطل بسيط في التهوية (المدخل).',
  ),
};

extension on TaskDetailsEntity {
  TaskDetailsEntity copyWith({TaskEntity? task}) {
    return TaskDetailsEntity(
      task: task ?? this.task,
      code: code,
      plannedDate: plannedDate,
      stageLabel: stageLabel,
      steps: steps,
      mapHint: mapHint,
      inspectorNote: inspectorNote,
    );
  }
}
