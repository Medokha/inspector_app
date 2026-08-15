import 'package:flutter/foundation.dart';

import 'package:inspector_app/features/auth/domain/entities/auth_result.dart';
import 'package:inspector_app/features/auth/domain/usecases/reset_password_usecase.dart';

class ResetPasswordController extends ChangeNotifier {
  ResetPasswordController({required ResetPasswordUseCase resetPasswordUseCase})
      : _resetPasswordUseCase = resetPasswordUseCase;

  final ResetPasswordUseCase _resetPasswordUseCase;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<AuthResult> resetPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    final result = await _resetPasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isLoading = false;
    _error = result.isSuccess ? null : (result.message ?? 'Reset password failed');
    notifyListeners();

    return result;
  }
}
