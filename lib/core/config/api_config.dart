import 'package:flutter/foundation.dart';

class ApiConfig {
  /// `flutter run -d chrome --dart-define=API_BASE_URL=https://localhost:44371`
  static const String _definedBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String? _resolvedBaseUrl;

  static String get baseUrl =>
      _resolvedBaseUrl ??
      (_definedBaseUrl.isNotEmpty ? _stripSlash(_definedBaseUrl) : _runtimeDefaultBaseUrl);

  static void remember(String url) {
    _resolvedBaseUrl = _stripSlash(url);
  }

  static List<String> get candidateBaseUrls {
    if (_resolvedBaseUrl != null) {
      return <String>[_resolvedBaseUrl!];
    }
    if (_definedBaseUrl.isNotEmpty) {
      return <String>[_stripSlash(_definedBaseUrl)];
    }
    return _runtimeCandidates;
  }

  static String get _runtimeDefaultBaseUrl => _runtimeCandidates.first;

  /// IIS Express عندك على 44371 — ده اللي Swagger شغال عليه.
  static List<String> get _runtimeCandidates {
    final host = _localHost;
    return <String>[
      'https://$host:44371',
      'http://$host:56615',
      'https://$host:7100',
      'http://$host:5187',
    ];
  }

  static String get _localHost {
    if (kIsWeb) return 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return 'localhost';
  }

  static String _stripSlash(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
