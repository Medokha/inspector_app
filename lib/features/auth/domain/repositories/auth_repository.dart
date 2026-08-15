import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> resetPassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> logout();
}
