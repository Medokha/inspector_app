class AuthResult {
  const AuthResult({required this.isSuccess, this.token, this.message});

  final bool isSuccess;
  final String? token;
  final String? message;
}
