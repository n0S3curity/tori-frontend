import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_model.freezed.dart';
part 'business_model.g.dart';

@freezed
sealed class AddressModel with _$AddressModel {
  const factory AddressModel({
    String? formatted,
    double? lat,
    double? lng,
    String? placeId,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);
}

@freezed
sealed class BusinessModel with _$BusinessModel {
  const factory BusinessModel({
    required String id,
    required String name,
    String? logo,
    AddressModel? address,
    required String ownerId,
    @Default(false) bool isDisabled,
    @Default(false) bool usersDisabled,
    @Default(true) bool remindersEnabled,
    String? createdAt,
  }) = _BusinessModel;

  factory BusinessModel.fromJson(Map<String, dynamic> json) => _$BusinessModelFromJson(json);
}
