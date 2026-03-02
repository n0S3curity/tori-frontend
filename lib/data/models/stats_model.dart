import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_model.freezed.dart';
part 'stats_model.g.dart';

@freezed
sealed class StatsModel with _$StatsModel {
  const factory StatsModel({
    required String period,
    required int totalAppointments,
    required int completedAppointments,
    required int canceledAppointments,
    required double cancellationRate,
    required double totalBenefit,
    required double actualWorkingHours,
    int? newClientsCount,
  }) = _StatsModel;

  factory StatsModel.fromJson(Map<String, dynamic> json) => _$StatsModelFromJson(json);
}
