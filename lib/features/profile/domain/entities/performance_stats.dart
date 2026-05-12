class PerformanceStats {
  const PerformanceStats({
    required this.completed,
    required this.pending,
    required this.rejected,
    required this.late,
  });

  final int completed;
  final int pending;
  final int rejected;
  final int late;
}
