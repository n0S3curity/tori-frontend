import 'package:freezed_annotation/freezed_annotation.dart';

part 'registered_business_model.freezed.dart';
part 'registered_business_model.g.dart';

@freezed
sealed class RegisteredBusinessModel with _$RegisteredBusinessModel {
  const factory RegisteredBusinessModel({
    required String businessId,
    required String status,
    String? approvedAt,
  }) = _RegisteredBusinessModel;

  factory RegisteredBusinessModel.fromJson(Map<String, dynamic> json) =>
      _$RegisteredBusinessModelFromJson(json);
}
