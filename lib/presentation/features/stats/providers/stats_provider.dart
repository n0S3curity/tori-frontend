import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/remote/stats_remote_datasource.dart';
import '../../../../data/models/stats_model.dart';
import '../../../features/auth/providers/auth_provider.dart';

final statsRemoteDsProvider = Provider<StatsRemoteDataSource>((ref) {
  return StatsRemoteDataSource(ref.read(apiClientProvider));
});

// Parameters for stats query
class StatsParams {
  const StatsParams({required this.id, required this.period, this.isBusinessStats = false});
  final String id;
  final String period;
  final bool isBusinessStats;

  @override
  bool operator ==(Object other) =>
      other is StatsParams && id == other.id && period == other.period && isBusinessStats == other.isBusinessStats;

  @override
  int get hashCode => Object.hash(id, period, isBusinessStats);
}

final statsProvider = FutureProviderFamily<StatsModel, StatsParams>((ref, params) async {
  final ds = ref.read(statsRemoteDsProvider);
  if (params.isBusinessStats) {
    return ds.getBusinessStats(params.id, period: params.period);
  }
  return ds.getSpStats(params.id, period: params.period);
});

final selectedPeriodProvider = StateProvider<String>((_) => 'monthly');
