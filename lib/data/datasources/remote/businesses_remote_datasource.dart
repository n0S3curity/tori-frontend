import '../../models/business_model.dart';
import '../../models/user_model.dart';
import 'api_client.dart';

class BusinessesRemoteDataSource {
  BusinessesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<BusinessModel>> listBusinesses() async {
    final response = await _client.get<Map<String, dynamic>>('/businesses');
    final list = (response.data!['data'] as Map<String, dynamic>)['businesses'] as List;
    return list.map((e) => BusinessModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BusinessModel> getBusiness(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/businesses/$id');
    return BusinessModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['business'] as Map<String, dynamic>,
    );
  }

  Future<BusinessModel> createBusiness(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>('/businesses', data: data);
    return BusinessModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['business'] as Map<String, dynamic>,
    );
  }

  Future<BusinessModel> updateBusiness(String id, Map<String, dynamic> data) async {
    final response = await _client.put<Map<String, dynamic>>('/businesses/$id', data: data);
    return BusinessModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['business'] as Map<String, dynamic>,
    );
  }

  Future<void> requestRegistration(String businessId) =>
      _client.post<void>('/businesses/$businessId/registrations');

  Future<List<UserModel>> listPendingRegistrations(String businessId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/businesses/$businessId/registrations',
    );
    final list = (response.data!['data'] as Map<String, dynamic>)['users'] as List;
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approveRegistration(String businessId, String userId) =>
      _client.put<void>('/businesses/$businessId/registrations/$userId/approve');

  Future<void> rejectRegistration(String businessId, String userId) =>
      _client.put<void>('/businesses/$businessId/registrations/$userId/reject');

  Future<void> disableBusiness(String id) =>
      _client.put<void>('/businesses/$id/disable');

  Future<void> toggleReminders(String id, {required bool enabled}) =>
      _client.put<void>('/businesses/$id/reminders', data: {'remindersEnabled': enabled});
}
