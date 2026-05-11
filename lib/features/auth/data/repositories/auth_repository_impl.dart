import 'package:inspector_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';
import 'package:inspector_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final json = await _remote.login(email: email, password: password);
      final token = json['token']?.toString() ?? json['accessToken']?.toString();
      final message = json['message']?.toString();
      return AuthResult(isSuccess: true, token: token, message: message);
    } on AuthException catch (e) {
      return AuthResult(isSuccess: false, message: e.message);
    } catch (_) {
      return const AuthResult(isSuccess: false, message: 'Login failed');
    }
  }
}
