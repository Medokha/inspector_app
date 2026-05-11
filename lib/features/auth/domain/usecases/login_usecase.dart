import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';
import 'package:inspector_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthResult> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
