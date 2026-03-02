import 'package:freezed_annotation/freezed_annotation.dart';
import 'registered_business_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    @Default(false) bool phoneVerified,
    String? profileImage,
    required String role,
    @Default('he') String language,
    String? fcmToken,
    @Default(false) bool isDisabled,
    @Default([]) List<RegisteredBusinessModel> registeredBusinesses,
    String? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
