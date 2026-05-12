enum TaskStepStatus {
  done,
  inProgress,
  pending,
}

class TaskStepEntity {
  const TaskStepEntity({
    required this.title,
    required this.status,
    required this.timeLabel,
  });

  final String title;
  final TaskStepStatus status;
  final String timeLabel;
}
