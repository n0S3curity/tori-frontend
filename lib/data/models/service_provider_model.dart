import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'service_provider_model.freezed.dart';
part 'service_provider_model.g.dart';

@freezed
sealed class ServiceProviderModel with _$ServiceProviderModel {
  const factory ServiceProviderModel({
    required String id,
    required String businessId,
    @Default(true) bool isActive,
    @Default(30) int reminderMinutesBefore,
    UserModel? userId, // populated
    String? createdAt,
  }) = _ServiceProviderModel;

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceProviderModelFromJson(json);
}
