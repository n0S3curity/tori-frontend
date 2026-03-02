import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_model.freezed.dart';
part 'service_model.g.dart';

@freezed
sealed class TimeRangeModel with _$TimeRangeModel {
  const factory TimeRangeModel({
    required String day,
    required String start,
    required String end,
  }) = _TimeRangeModel;

  factory TimeRangeModel.fromJson(Map<String, dynamic> json) => _$TimeRangeModelFromJson(json);
}

@freezed
sealed class ServiceModel with _$ServiceModel {
  const factory ServiceModel({
    required String id,
    required String serviceProviderId,
    required String businessId,
    required String name,
    required int durationMinutes,
    required double price,
    @Default([]) List<String> availableDays,
    @Default([]) List<TimeRangeModel> timeRanges,
    @Default('') String notes,
    String? image,
    String? icon,
    @Default(true) bool isActive,
    String? createdAt,
  }) = _ServiceModel;

  factory ServiceModel.fromJson(Map<String, dynamic> json) => _$ServiceModelFromJson(json);
}
