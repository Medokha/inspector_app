import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static const _kToken = 'inspector_auth_token';
  static const _kEmail = 'inspector_auth_email';
  static const _kName = 'inspector_auth_name';
  static const _kInspectorId = 'inspector_auth_inspector_id';
  static const _kUserId = 'inspector_auth_user_id';

  String? _token;
  String? _email;
  String? _name;
  String? _inspectorId;
  String? _userId;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  String? get inspectorId => _inspectorId;
  String? get userId => _userId;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  String get initials {
    final parts = (_name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'م';
    String first(String value) => String.fromCharCodes(value.runes.take(1));
    if (parts.length == 1) return first(parts.first);
    return '${first(parts.first)}${first(parts.last)}';
  }

  Future<void> save({
    String? token,
    String? email,
    String? name,
    String? inspectorId,
    String? userId,
  }) async {
    _token = token ?? _token;
    _email = email ?? _email;
    _name = name ?? _name;
    _inspectorId = inspectorId ?? _inspectorId;
    _userId = userId ?? _userId;
    await persist();
  }

  void clear() {
    _token = null;
    _email = null;
    _name = null;
    _inspectorId = null;
    _userId = null;
    persist();
  }

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    _email = prefs.getString(_kEmail);
    _name = prefs.getString(_kName);
    _inspectorId = prefs.getString(_kInspectorId);
    _userId = prefs.getString(_kUserId);
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token == null || _token!.isEmpty) {
      await prefs.remove(_kToken);
      await prefs.remove(_kEmail);
      await prefs.remove(_kName);
      await prefs.remove(_kInspectorId);
      await prefs.remove(_kUserId);
      return;
    }
    await prefs.setString(_kToken, _token!);
    if (_email != null) await prefs.setString(_kEmail, _email!);
    if (_name != null) await prefs.setString(_kName, _name!);
    if (_inspectorId != null) await prefs.setString(_kInspectorId, _inspectorId!);
    if (_userId != null) await prefs.setString(_kUserId, _userId!);
  }
}
