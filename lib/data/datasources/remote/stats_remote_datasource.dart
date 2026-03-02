import '../../models/stats_model.dart';
import 'api_client.dart';

class StatsRemoteDataSource {
  StatsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<StatsModel> getSpStats(
    String spId, {
    String period = 'monthly',
    String? date,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/stats/sp/$spId',
      queryParameters: {'period': period, if (date != null) 'date': date},
    );
    return StatsModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['stats'] as Map<String, dynamic>,
    );
  }

  Future<StatsModel> getBusinessStats(
    String businessId, {
    String period = 'monthly',
    String? date,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/stats/business/$businessId',
      queryParameters: {'period': period, if (date != null) 'date': date},
    );
    return StatsModel.fromJson(
      (response.data!['data'] as Map<String, dynamic>)['stats'] as Map<String, dynamic>,
    );
  }
}
