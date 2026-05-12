enum ReportStatus {
  accepted,
  rejected,
  pending,
}

class ReportItem {
  const ReportItem({
    required this.title,
    required this.status,
    required this.dateLabel,
  });

  final String title;
  final ReportStatus status;
  final String dateLabel;
}
