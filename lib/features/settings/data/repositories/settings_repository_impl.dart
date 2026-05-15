import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspector_app/features/settings/domain/entities/app_settings.dart';
import 'package:inspector_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _key = 'app_settings';

  @override
  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) {
      return const AppSettings(
        newTasks: true,
        reportApprovals: true,
        deadlineReminders: false,
        offlineMapsEnabled: true,
        isDarkMode: false,
        storageUsedLabel: '٢٥٠ MB',
        appVersion: 'v1.0.0',
      );
    }
    return AppSettings.fromJson(jsonDecode(json));
  }

  @override
  Future<AppSettings> updateSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
    return settings;
  }
}
