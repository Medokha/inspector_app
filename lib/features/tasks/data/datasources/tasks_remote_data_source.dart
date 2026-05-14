import 'dart:convert';
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
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load tasks');
  }

  Future<Map<String, dynamic>> getTaskDetails(String id) async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Tasks/$id');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load task details');
  }
}
