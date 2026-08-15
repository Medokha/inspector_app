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
