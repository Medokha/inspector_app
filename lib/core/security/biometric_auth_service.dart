import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تسجيل دخول ببصمة/وجه بعد أول تسجيل ناجح بكلمة المرور.
class BiometricAuthService {
  BiometricAuthService._();

  static const _enabledKey = 'inspector_biometric_enabled';
  static const _emailKey = 'inspector_biometric_email';

  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> get isDeviceSupported async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> get canCheckBiometrics async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<String?> get savedEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// يُستدعى بعد أول دخول ناجح بكلمة المرور.
  static Future<void> enableAfterPasswordLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setString(_emailKey, email.trim());
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
  }

  /// يطلب البصمة/الوجه. عند النجاح يُرجع البريد المحفوظ.
  static Future<String?> authenticate({String reason = 'أكد هويتك للمتابعة'}) async {
    try {
      final enabled = await isEnabled;
      if (!enabled) return null;
      final email = await savedEmail;
      if (email == null || email.isEmpty) return null;

      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return ok ? email : null;
    } catch (e) {
      debugPrint('BiometricAuth failed: $e');
      return null;
    }
  }
}
