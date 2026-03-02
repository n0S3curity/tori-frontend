import '../../models/appointment_model.dart';
import 'api_client.dart';

class AppointmentsRemoteDataSource {
  AppointmentsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AppointmentModel> bookAppointment(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>('/appointments', data: data);
    return AppointmentModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['appointment'] as Map<String, dynamic>,
    );
  }

  Future<List<AppointmentModel>> listAppointments({
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/appointments',
      queryParameters: params,
    );
    final list = (response.data!['data'] as Map<String, dynamic>)['appointments'] as List;
    return list.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AppointmentModel> getAppointment(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/appointments/$id');
    return AppointmentModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['appointment'] as Map<String, dynamic>,
    );
  }

  Future<AppointmentModel> cancelAppointment(String id) async {
    final response =
        await _client.put<Map<String, dynamic>>('/appointments/$id/cancel');
    return AppointmentModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['appointment'] as Map<String, dynamic>,
    );
  }

  Future<List<AppointmentModel>> getHistory({Map<String, dynamic>? params}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/appointments/history',
      queryParameters: params,
    );
    final list = (response.data!['data'] as Map<String, dynamic>)['appointments'] as List;
    return list.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
