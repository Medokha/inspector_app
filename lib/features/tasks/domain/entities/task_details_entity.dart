import 'task_entity.dart';
import 'task_step_entity.dart';

class TaskDetailsEntity {
  const TaskDetailsEntity({
    required this.task,
    required this.code,
    required this.plannedDate,
    required this.stageLabel,
    required this.steps,
    this.mapHint,
    this.inspectorNote,
  });

  final TaskEntity task;
  final String code;
  final String plannedDate;
  final String stageLabel;
  final List<TaskStepEntity> steps;
  final String? mapHint;
  final String? inspectorNote;
}
