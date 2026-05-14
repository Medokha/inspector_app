import 'user.dart';

class AuthResult {
  const AuthResult({required this.isSuccess, this.token, this.message, this.user});

  final bool isSuccess;
  final String? token;
  final String? message;
  final User? user;
}
