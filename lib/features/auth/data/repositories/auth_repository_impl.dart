import 'package:inspector_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';
import 'package:inspector_app/features/auth/domain/entities/user.dart';
import 'package:inspector_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final json = await _remote.login(email: email, password: password);
      final token = json['token']?.toString() ?? json['accessToken']?.toString();
      final message = json['message']?.toString();

      if (token != null) {
        await _local.saveToken(token);
        if (json['user'] != null) {
          final user = User.fromJson(json['user'] as Map<String, dynamic>);
          await _local.saveUser(user);
          return AuthResult(isSuccess: true, token: token, message: message, user: user);
        }
      }
      
      return AuthResult(isSuccess: true, token: token, message: message);
    } on AuthException catch (e) {
      return AuthResult(isSuccess: false, message: e.message);
    } catch (_) {
      return const AuthResult(isSuccess: false, message: 'Login failed');
    }
  }

  @override
  Future<void> logout() async {
    final token = await _local.getToken();
    if (token != null) {
      try {
        await _remote.logout(token);
      } catch (_) {}
    }
    await _local.clear();
  }
}
