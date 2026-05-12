class AppSettings {
  const AppSettings({
    required this.newTasks,
    required this.reportApprovals,
    required this.deadlineReminders,
    required this.offlineMapsEnabled,
    required this.isDarkMode,
    required this.storageUsedLabel,
    required this.appVersion,
  });

  final bool newTasks;
  final bool reportApprovals;
  final bool deadlineReminders;
  final bool offlineMapsEnabled;
  final bool isDarkMode;
  final String storageUsedLabel;
  final String appVersion;

  AppSettings copyWith({
    bool? newTasks,
    bool? reportApprovals,
    bool? deadlineReminders,
    bool? offlineMapsEnabled,
    bool? isDarkMode,
  }) {
    return AppSettings(
      newTasks: newTasks ?? this.newTasks,
      reportApprovals: reportApprovals ?? this.reportApprovals,
      deadlineReminders: deadlineReminders ?? this.deadlineReminders,
      offlineMapsEnabled: offlineMapsEnabled ?? this.offlineMapsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      storageUsedLabel: storageUsedLabel,
      appVersion: appVersion,
    );
  }
}
