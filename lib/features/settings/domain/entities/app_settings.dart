class AppSettings {
  const AppSettings({
    required this.newTasks,
    required this.reportApprovals,
    required this.deadlineReminders,
    required this.offlineMapsEnabled,
    required this.storageUsedLabel,
    required this.appVersion,
  });

  final bool newTasks;
  final bool reportApprovals;
  final bool deadlineReminders;
  final bool offlineMapsEnabled;
  final String storageUsedLabel;
  final String appVersion;

  AppSettings copyWith({
    bool? newTasks,
    bool? reportApprovals,
    bool? deadlineReminders,
    bool? offlineMapsEnabled,
  }) {
    return AppSettings(
      newTasks: newTasks ?? this.newTasks,
      reportApprovals: reportApprovals ?? this.reportApprovals,
      deadlineReminders: deadlineReminders ?? this.deadlineReminders,
      offlineMapsEnabled: offlineMapsEnabled ?? this.offlineMapsEnabled,
      storageUsedLabel: storageUsedLabel,
      appVersion: appVersion,
    );
  }
}
