import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.validation({required String message}) = ValidationFailure;
  const factory Failure.unauthorized({String? message}) = UnauthorizedFailure;
  const factory Failure.forbidden({String? message}) = ForbiddenFailure;
  const factory Failure.notFound({String? message}) = NotFoundFailure;
  const factory Failure.conflict({String? message}) = ConflictFailure;
  const factory Failure.rateLimit() = RateLimitFailure;
  const factory Failure.server({String? message}) = ServerFailure;
  const factory Failure.network({String? message}) = NetworkFailure;
  const factory Failure.unknown({String? message}) = UnknownFailure;

  // Domain-specific
  const factory Failure.appointmentConflict() = AppointmentConflictFailure;
  const factory Failure.outsideHours() = OutsideHoursFailure;
  const factory Failure.clientNotApproved() = ClientNotApprovedFailure;
  const factory Failure.businessDisabled() = BusinessDisabledFailure;
  const factory Failure.userDisabled() = UserDisabledFailure;
}

extension FailureMessage on Failure {
  String get userMessage => when(
        validation: (msg) => msg,
        unauthorized: (msg) => msg ?? 'Session expired. Please log in again.',
        forbidden: (msg) => msg ?? 'You do not have permission to perform this action.',
        notFound: (msg) => msg ?? 'The requested resource was not found.',
        conflict: (msg) => msg ?? 'A conflict occurred.',
        rateLimit: () => 'Too many requests. Please wait a moment.',
        server: (msg) => msg ?? 'Server error. Please try again later.',
        network: (msg) => msg ?? 'Network error. Check your connection.',
        unknown: (msg) => msg ?? 'An unexpected error occurred.',
        appointmentConflict: () => 'This time slot is already booked.',
        outsideHours: () => 'Appointment is outside available hours.',
        clientNotApproved: () => 'You are not approved for this business yet.',
        businessDisabled: () => 'This business is currently unavailable.',
        userDisabled: () => 'Your account has been disabled.',
      );
}
