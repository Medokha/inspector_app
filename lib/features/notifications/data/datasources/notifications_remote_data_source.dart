import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inspector_app/core/config/api_config.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_local_data_source.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._client, this._authLocal);

  final http.Client _client;
  final AuthLocalDataSource _authLocal;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Notifications/me');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.cast<Map<String, dynamic>>();
    }

    throw Exception('Failed to load notifications');
  }

  Future<void> markAsRead(String id) async {
    final token = await _authLocal.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Notifications/$id/read');

    final response = await _client.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to mark notification as read');
    }
  }
}
