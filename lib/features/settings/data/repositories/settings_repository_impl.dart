import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/api_mappers.dart';
import 'package:inspector_app/features/settings/domain/entities/app_settings.dart';
import 'package:inspector_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._api);

  static const _kDark = 'inspector_dark_mode';
  static const _kOffline = 'inspector_offline_maps';

  final ApiClient _api;

  @override
  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();
    var newTasks = true;
    var reportApprovals = true;
    var deadlineReminders = true;

    try {
      final json = JsonMap.map(await _api.get('/api/Inspectors/me/settings'));
      newTasks = json['newTasks'] != false;
      reportApprovals = json['reportApprovals'] != false;
      deadlineReminders = json['deadlineReminders'] != false;
    } catch (_) {}

    return AppSettings(
      newTasks: newTasks,
      reportApprovals: reportApprovals,
      deadlineReminders: deadlineReminders,
      offlineMapsEnabled: prefs.getBool(_kOffline) ?? true,
      isDarkMode: prefs.getBool(_kDark) ?? false,
      storageUsedLabel: 'محلي',
      appVersion: 'v${info.version}',
    );
  }

  @override
  Future<AppSettings> updateSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDark, settings.isDarkMode);
    await prefs.setBool(_kOffline, settings.offlineMapsEnabled);

    try {
      await _api.put(
        '/api/Inspectors/me/settings',
        body: <String, bool>{
          'newTasks': settings.newTasks,
          'reportApprovals': settings.reportApprovals,
          'deadlineReminders': settings.deadlineReminders,
        },
      );
    } catch (_) {}

    return settings;
  }
}
