import 'package:inspector_app/core/network/api_mappers.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_session.dart';
import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';
import 'package:inspector_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._session);

  final AuthRemoteDataSource _remote;
  final AuthSession _session;

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final json = await _remote.login(email: email, password: password);
      final token = JsonMap.str(json['token']).isEmpty
          ? JsonMap.str(json['accessToken'])
          : JsonMap.str(json['token']);
      final user = JsonMap.map(json['user']);
      if (token.isEmpty) {
        return const AuthResult(isSuccess: false, message: 'الخادم لم يُرجع توكن الدخول');
      }
      await _session.save(
        token: token,
        email: JsonMap.str(user['email'], email),
        name: JsonMap.str(user['name']),
        inspectorId: JsonMap.str(user['inspectorId']),
        userId: JsonMap.str(user['id']),
      );
      return AuthResult(isSuccess: true, token: token, message: json['message']?.toString());
    } catch (e) {
      final error = toAuthException(e);
      return AuthResult(isSuccess: false, message: error.message);
    }
  }

  @override
  Future<AuthResult> resetPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final json = await _remote.resetPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return AuthResult(isSuccess: true, message: json['message']?.toString());
    } catch (e) {
      final error = toAuthException(e);
      return AuthResult(isSuccess: false, message: error.message);
    }
  }

  @override
  Future<void> logout() async {
    _session.clear();
  }
}
