import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/appointments_repository.dart';

class CancelAppointmentUseCase {
  CancelAppointmentUseCase(this._repository);

  final AppointmentsRepository _repository;

  Future<Either<Failure, AppointmentEntity>> call(String appointmentId) =>
      _repository.cancelAppointment(appointmentId);
}
