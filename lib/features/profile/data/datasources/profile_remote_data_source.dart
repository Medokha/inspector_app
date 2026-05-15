import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inspector_app/core/config/api_config.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_local_data_source.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client, this._authLocal);

  final http.Client _client;
  final AuthLocalDataSource _authLocal;

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Inspectors/me');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load profile');
  }

  Future<Map<String, dynamic>> getStats() async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Inspectors/me/stats');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load stats');
  }

  Future<List<dynamic>> getReports() async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Inspectors/me/reports');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load reports');
  }
}
