import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@freezed
sealed class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    required String id,
    required String businessId,
    required String serviceProviderId,
    required String serviceId,
    required String clientId,
    required String bookedBy,
    required String scheduledAt,
    required String endsAt,
    @Default('pending') String status,
    String? canceledBy,
    String? canceledAt,
    String? calendarEventId,
    String? reminderSentAt,
    @Default('') String notes,
    // Populated fields
    Map<String, dynamic>? service,
    Map<String, dynamic>? client,
    String? createdAt,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
}
