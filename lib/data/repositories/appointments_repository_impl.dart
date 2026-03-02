import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/remote/appointments_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  AppointmentsRepositoryImpl(this._dataSource);

  final AppointmentsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, AppointmentEntity>> bookAppointment(Map<String, dynamic> data) async {
    try {
      final model = await _dataSource.bookAppointment(data);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> listAppointments({
    Map<String, dynamic>? params,
  }) async {
    try {
      final models = await _dataSource.listAppointments(params: params);
      return right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> getAppointment(String id) async {
    try {
      final model = await _dataSource.getAppointment(id);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> cancelAppointment(String id) async {
    try {
      final model = await _dataSource.cancelAppointment(id);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getHistory({
    Map<String, dynamic>? params,
  }) async {
    try {
      final models = await _dataSource.getHistory(params: params);
      return right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }
}

extension _AppointmentModelMapper on AppointmentModel {
  AppointmentEntity toEntity() => AppointmentEntity(
        id: id,
        businessId: businessId,
        serviceProviderId: serviceProviderId,
        serviceId: serviceId,
        clientId: clientId,
        bookedBy: bookedBy,
        scheduledAt: DateTime.parse(scheduledAt),
        endsAt: DateTime.parse(endsAt),
        status: status,
        notes: notes,
        service: service,
        client: client,
      );
}
