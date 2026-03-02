import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';

abstract class AppointmentsRepository {
  Future<Either<Failure, AppointmentEntity>> bookAppointment(Map<String, dynamic> data);
  Future<Either<Failure, List<AppointmentEntity>>> listAppointments({Map<String, dynamic>? params});
  Future<Either<Failure, AppointmentEntity>> getAppointment(String id);
  Future<Either<Failure, AppointmentEntity>> cancelAppointment(String id);
  Future<Either<Failure, List<AppointmentEntity>>> getHistory({Map<String, dynamic>? params});
}
