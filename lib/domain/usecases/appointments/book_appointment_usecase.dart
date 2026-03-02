import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/appointments_repository.dart';

class BookAppointmentUseCase {
  BookAppointmentUseCase(this._repository);

  final AppointmentsRepository _repository;

  Future<Either<Failure, AppointmentEntity>> call({
    required String serviceProviderId,
    required String serviceId,
    required DateTime scheduledAt,
    String? clientId,
    String notes = '',
  }) =>
      _repository.bookAppointment({
        'serviceProviderId': serviceProviderId,
        'serviceId': serviceId,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        if (clientId != null) 'clientId': clientId,
        'notes': notes,
      });
}
