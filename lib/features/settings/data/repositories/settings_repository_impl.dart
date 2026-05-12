import 'package:inspector_app/features/settings/domain/entities/app_settings.dart';
import 'package:inspector_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  AppSettings _settings = const AppSettings(
    newTasks: true,
    reportApprovals: true,
    deadlineReminders: false,
    offlineMapsEnabled: true,
    isDarkMode: false,
    storageUsedLabel: '٢٥٠ MB',
    appVersion: 'v2.1.0',
  );

  @override
  Future<AppSettings> getSettings() async {
    return _settings;
  }

  @override
  Future<AppSettings> updateSettings(AppSettings settings) async {
    _settings = settings;
    return _settings;
  }
}
