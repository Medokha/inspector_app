enum ReportStatus {
  accepted,
  rejected,
  pending,
}

class ReportItem {
  const ReportItem({
    required this.id,
    required this.title,
    required this.status,
    required this.dateLabel,
  });

  final String id;
  final String title;
  final ReportStatus status;
  final String dateLabel;
}
