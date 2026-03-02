import 'api_client.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> updateFcmToken(String token) =>
      _client.put<void>('/notifications/fcm-token', data: {'fcmToken': token});

  Future<Map<String, dynamic>> sendCustom({
    required String title,
    required String body,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/notifications/custom',
      data: {'title': title, 'body': body},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendBusiness({
    required String title,
    required String body,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/notifications/business',
      data: {'title': title, 'body': body},
    );
    return response.data!['data'] as Map<String, dynamic>;
  }
}
