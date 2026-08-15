import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/api_mappers.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> login({required String email, required String password}) {
    return _api.post(
      '/api/Auth/login',
      body: <String, String>{
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _api.post(
      '/api/Auth/change-password',
      body: <String, String>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> logout(String token) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Auth/logout');

    final response = await _client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // We don't necessarily throw here on logout failure, 
      // but we could log it.
    }
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Auth/change-password');

    final response = await _client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body);
      throw AuthException(body['message'] ?? 'فشل تغيير كلمة المرور', statusCode: response.statusCode);
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

AuthException toAuthException(Object error) {
  if (error is ApiException) {
    return AuthException(error.message, statusCode: error.statusCode);
  }
  return AuthException(JsonMap.str(error, 'Request failed'));
}
