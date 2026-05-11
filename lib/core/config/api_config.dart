import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Override at build/run time:
  /// `flutter run --dart-define=API_BASE_URL=https://...`
  static const String _definedBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl =>
      _definedBaseUrl.isNotEmpty ? _definedBaseUrl : _runtimeDefaultBaseUrl;

  static String get _runtimeDefaultBaseUrl {
    if (kIsWeb) return 'https://localhost:44357';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://10.0.2.2:44357';
    }
    return 'https://localhost:44357';
  }
}
