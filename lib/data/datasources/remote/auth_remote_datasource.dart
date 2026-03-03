import '../../../data/models/user_model.dart';
import 'api_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> googleLogin({
    required String idToken,
    required String role,
    String? businessName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/google',
      data: {
        'idToken': idToken,
        'role': role,
        if (businessName != null) 'businessName': businessName,
      },
    );
    return response.data!['data'] as Map<String, dynamic>;
  }

  Future<void> sendOtp(String phone) async {
    await _client.post<void>('/auth/otp/send', data: {'phone': phone});
  }

  Future<UserModel> verifyOtp({
    required String phone,
    required String sessionInfo,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: {'phone': phone, 'sessionInfo': sessionInfo, 'code': code},
    );
    return UserModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response =
        await _client.put<Map<String, dynamic>>('/users/me', data: data);
    return UserModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['user']
          as Map<String, dynamic>,
    );
  }

  Future<void> logout() => _client.post<void>('/auth/logout');

  Future<String> refresh() async {
    final response = await _client.post<Map<String, dynamic>>('/auth/refresh');
    return (response.data!['data'] as Map<String, dynamic>)['token'] as String;
  }
}
