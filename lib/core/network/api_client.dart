import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:inspector_app/core/config/api_config.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_session.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._client, this._session);

  final http.Client _client;
  final AuthSession _session;

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Duration? timeout,
  }) async {
    final json = await _send('POST', path, body: body, timeout: timeout);
    return _asMap(json);
  }

  Future<Map<String, dynamic>> put(String path, {Object? body}) async {
    final json = await _send('PUT', path, body: body);
    return _asMap(json);
  }

  Future<Map<String, dynamic>> patch(String path, {Object? body}) async {
    final json = await _send('PATCH', path, body: body);
    return _asMap(json);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
  }) async {
    Object? lastError;
    for (final base in ApiConfig.candidateBaseUrls) {
      try {
        final uri = Uri.parse('$base$path');
        final request = http.MultipartRequest('POST', uri);
        request.headers['Accept'] = 'application/json';
        if (_session.token != null && _session.token!.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer ${_session.token}';
        }
        if (fields != null) {
          request.fields.addAll(fields);
        }
        request.files.addAll(files);

        final streamed = await _client.send(request).timeout(const Duration(seconds: 90));
        final response = await http.Response.fromStream(streamed);
        final decoded = _decode(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          ApiConfig.remember(base);
          return _asMap(decoded);
        }
        final map = _asMap(decoded);
        throw ApiException(
          (map['message'] ?? map['error'] ?? 'فشل الطلب').toString(),
          statusCode: response.statusCode,
        );
      } on ApiException catch (error) {
        if (error.statusCode != null) rethrow;
        lastError = error;
      } catch (error) {
        lastError = error;
        if (!_isUnreachable(error)) {
          throw ApiException(_networkMessage(error, base));
        }
      }
    }
    throw ApiException(_networkMessage(lastError, ApiConfig.baseUrl));
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    Duration? timeout,
  }) async {
    Object? lastError;
    for (final base in ApiConfig.candidateBaseUrls) {
      try {
        final result = await _sendTo(
          base,
          method,
          path,
          body: body,
          query: query,
          timeout: timeout,
        );
        ApiConfig.remember(base);
        return result;
      } on ApiException catch (error) {
        if (error.statusCode != null) rethrow;
        lastError = error;
      } catch (error) {
        lastError = error;
        if (!_isUnreachable(error)) {
          throw ApiException(_networkMessage(error, base));
        }
      }
    }
    throw ApiException(_networkMessage(lastError, ApiConfig.baseUrl));
  }

  Future<dynamic> _sendTo(
    String base,
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    Duration? timeout,
  }) async {
    var uri = Uri.parse('$base$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (_session.token != null && _session.token!.isNotEmpty)
        'Authorization': 'Bearer ${_session.token}',
    };

    final encoded = body == null ? null : jsonEncode(body);
    final wait = timeout ?? const Duration(seconds: 12);
    late http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await _client.post(uri, headers: headers, body: encoded).timeout(wait);
          break;
        case 'PUT':
          response = await _client.put(uri, headers: headers, body: encoded).timeout(wait);
          break;
        case 'PATCH':
          response = await _client.patch(uri, headers: headers, body: encoded).timeout(wait);
          break;
        default:
          response = await _client.get(uri, headers: headers).timeout(wait);
      }
    } catch (error) {
      throw ApiException(_networkMessage(error, base));
    }

    final decoded = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final map = _asMap(decoded);
    final message = (map['message'] ?? map['error'] ?? 'فشل الطلب').toString();
    throw ApiException(message, statusCode: response.statusCode);
  }

  bool _isUnreachable(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('timeout') ||
        text.contains('connection') ||
        text.contains('handshake') ||
        text.contains('socket') ||
        text.contains('certificate') ||
        text.contains('failed host lookup') ||
        text.contains('xmlhttprequest');
  }

  String _networkMessage(Object? error, String base) {
    final text = error?.toString() ?? '';
    if (text.toLowerCase().contains('timeout')) {
      return 'انتهت مهلة الاتصال بـ $base';
    }
    if (text.toLowerCase().contains('handshake') || text.toLowerCase().contains('certificate')) {
      return 'فشل شهادة SSL مع $base — استخدم http://localhost:5187';
    }
    return 'تعذر الاتصال بالخادم ($base). تأكد أن WaqfLand.API يعمل.';
  }

  dynamic _decode(String bodyText) {
    if (bodyText.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(bodyText);
    } catch (_) {
      return <String, dynamic>{'message': bodyText};
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}
