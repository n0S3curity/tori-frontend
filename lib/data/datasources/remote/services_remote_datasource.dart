import '../../models/service_model.dart';
import 'api_client.dart';

class ServicesRemoteDataSource {
  ServicesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ServiceModel>> listServices(String spId) async {
    final response =
        await _client.get<Map<String, dynamic>>('/service-providers/$spId/services');
    final list = (response.data!['data'] as Map<String, dynamic>)['services'] as List;
    return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ServiceModel> getService(String spId, String serviceId) async {
    final response = await _client
        .get<Map<String, dynamic>>('/service-providers/$spId/services/$serviceId');
    return ServiceModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['service'] as Map<String, dynamic>,
    );
  }

  Future<ServiceModel> createService(String spId, Map<String, dynamic> data) async {
    final response = await _client
        .post<Map<String, dynamic>>('/service-providers/$spId/services', data: data);
    return ServiceModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['service'] as Map<String, dynamic>,
    );
  }

  Future<ServiceModel> updateService(
    String spId,
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/service-providers/$spId/services/$serviceId',
      data: data,
    );
    return ServiceModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['service'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteService(String spId, String serviceId) =>
      _client.delete<void>('/service-providers/$spId/services/$serviceId');
}
