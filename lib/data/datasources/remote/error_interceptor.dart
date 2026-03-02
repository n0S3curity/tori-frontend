import 'package:dio/dio.dart';
import '../../../core/errors/failures.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _mapError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: failure,
        type: err.type,
      ),
    );
  }

  Failure _mapError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const Failure.network();
    }

    final statusCode = err.response?.statusCode;
    final errorCode = err.response?.data?['error'] as String?;
    final message = err.response?.data?['message'] as String?;

    // Domain-specific error codes
    switch (errorCode) {
      case 'APPOINTMENT_CONFLICT':
        return const Failure.appointmentConflict();
      case 'APPOINTMENT_OUTSIDE_HOURS':
        return const Failure.outsideHours();
      case 'CLIENT_NOT_APPROVED':
        return const Failure.clientNotApproved();
      case 'AUTH_BUSINESS_DISABLED':
        return const Failure.businessDisabled();
      case 'AUTH_USER_DISABLED':
        return const Failure.userDisabled();
    }

    switch (statusCode) {
      case 400:
        return Failure.validation(message: message ?? 'Validation error');
      case 401:
        return const Failure.unauthorized();
      case 403:
        return Failure.forbidden(message: message);
      case 404:
        return Failure.notFound(message: message);
      case 409:
        return Failure.conflict(message: message);
      case 429:
        return const Failure.rateLimit();
      case 500:
        return Failure.server(message: message);
      default:
        return Failure.unknown(message: message);
    }
  }
}
