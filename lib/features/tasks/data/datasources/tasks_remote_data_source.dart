import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inspector_app/core/config/api_config.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_local_data_source.dart';

class TasksRemoteDataSource {
  TasksRemoteDataSource(this._client, this._authLocal);

  final http.Client _client;
  final AuthLocalDataSource _authLocal;

  Future<Map<String, dynamic>> getTasks({
    String? date,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final token = await _authLocal.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (date != null) queryParams['date'] = date;
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tasks').replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load tasks');
  }

  Future<Map<String, dynamic>> getTaskDetails(String id) async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tasks/$id');
    final response = await _client.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load task details');
  }

  Future<Map<String, dynamic>> getRoute({String? date}) async {
    final token = await _authLocal.getToken();
    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tasks/route').replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load route');
  }

  Future<void> submitReport(String taskId, Map<String, dynamic> data) async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tasks/$taskId/report');
    final response = await _client.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to submit report');
    }
  }

  Future<void> uploadMedia(String taskId, File file) async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tasks/$taskId/media');
    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      await http.MultipartFile.fromPath(
        'File',
        file.path,
        filename: file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'file.bin',
      ),
    );

    final streamed = await _client.send(request);
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Failed to upload media');
    }
  }
}
