import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/remote/stats_remote_datasource.dart';
import '../../../../data/models/stats_model.dart';
import '../../../features/auth/providers/auth_provider.dart';

final statsRemoteDsProvider = Provider<StatsRemoteDataSource>((ref) {
  return StatsRemoteDataSource(ref.read(apiClientProvider));
});

// Parameters for stats query
class StatsParams {
  const StatsParams({
    required this.id,
    required this.period,
    this.isBusinessStats = false,
    this.date,
  });
  final String id;
  final String period;
  final bool isBusinessStats;
  final String? date; // ISO-8601 date string: yyyy-MM-dd

  @override
  bool operator ==(Object other) =>
      other is StatsParams &&
      id == other.id &&
      period == other.period &&
      isBusinessStats == other.isBusinessStats &&
      date == other.date;

  @override
  int get hashCode => Object.hash(id, period, isBusinessStats, date);
}

final statsProvider = FutureProviderFamily<StatsModel, StatsParams>((ref, params) async {
  final ds = ref.read(statsRemoteDsProvider);
  if (params.isBusinessStats) {
    return ds.getBusinessStats(params.id, period: params.period, date: params.date);
  }
  return ds.getSpStats(params.id, period: params.period, date: params.date);
});

final selectedPeriodProvider = StateProvider<String>((_) => 'monthly');

/// The reference date for stats. Defaults to today.
final selectedStatsDateProvider = StateProvider<DateTime>((_) => DateTime.now());
