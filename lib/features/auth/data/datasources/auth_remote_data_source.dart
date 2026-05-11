import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:inspector_app/core/config/api_config.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final http.Client _client;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Auth/login');

    final response = await _client.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    final bodyText = response.body;
    Map<String, dynamic> json;
    try {
      json = bodyText.isEmpty ? <String, dynamic>{} : (jsonDecode(bodyText) as Map<String, dynamic>);
    } catch (_) {
      json = <String, dynamic>{'message': bodyText};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return <String, dynamic>{
        'statusCode': response.statusCode,
        ...json,
      };
    }

    final message = (json['message'] ?? json['error'] ?? 'Login failed').toString();
    throw AuthException(message, statusCode: response.statusCode);
  }
}

class AuthException implements Exception {
  AuthException(this.message, {required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => 'AuthException($statusCode): $message';
}
