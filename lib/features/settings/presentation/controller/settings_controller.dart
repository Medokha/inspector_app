import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/settings/domain/entities/app_settings.dart';
import 'package:inspector_app/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:inspector_app/features/settings/domain/usecases/update_settings_usecase.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    required GetSettingsUseCase getSettings,
    required UpdateSettingsUseCase updateSettings,
  })  : _getSettings = getSettings,
        _updateSettings = updateSettings;

  final GetSettingsUseCase _getSettings;
  final UpdateSettingsUseCase _updateSettings;

  AppSettings? _settings;
  bool _isLoading = false;

  AppSettings? get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _getSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> update(AppSettings settings) async {
    _settings = await _updateSettings(settings);
    notifyListeners();
  }
}
