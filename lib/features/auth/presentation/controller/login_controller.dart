import 'package:flutter/foundation.dart';

import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';
import 'package:inspector_app/features/auth/domain/usecases/login_usecase.dart';

import 'package:inspector_app/features/auth/presentation/controller/session_controller.dart';

class LoginController extends ChangeNotifier {
  LoginController({
    required LoginUseCase loginUseCase,
    required SessionController sessionController,
  })  : _loginUseCase = loginUseCase,
        _sessionController = sessionController;

  final LoginUseCase _loginUseCase;
  final SessionController _sessionController;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<AuthResult> login({required String email, required String password}) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    final result = await _loginUseCase(email: email, password: password);

    if (result.isSuccess && result.user != null) {
      _sessionController.setUser(result.user);
    }

    _isLoading = false;
    _error = result.isSuccess ? null : (result.message ?? 'Login failed');
    notifyListeners();

    return result;
  }
}
