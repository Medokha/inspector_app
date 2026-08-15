import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';
import 'package:inspector_app/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthResult> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.resetPassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
