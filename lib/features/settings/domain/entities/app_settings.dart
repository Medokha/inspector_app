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

  Map<String, dynamic> toJson() => {
        'newTasks': newTasks,
        'reportApprovals': reportApprovals,
        'deadlineReminders': deadlineReminders,
        'offlineMapsEnabled': offlineMapsEnabled,
        'isDarkMode': isDarkMode,
        'storageUsedLabel': storageUsedLabel,
        'appVersion': appVersion,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        newTasks: json['newTasks'] as bool? ?? true,
        reportApprovals: json['reportApprovals'] as bool? ?? true,
        deadlineReminders: json['deadlineReminders'] as bool? ?? false,
        offlineMapsEnabled: json['offlineMapsEnabled'] as bool? ?? true,
        isDarkMode: json['isDarkMode'] as bool? ?? false,
        storageUsedLabel: json['storageUsedLabel'] as String? ?? '',
        appVersion: json['appVersion'] as String? ?? '',
      );
}
