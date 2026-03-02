import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/service_entity.dart';
import '../datasources/remote/services_remote_datasource.dart';
import '../models/service_model.dart';

class ServicesRepositoryImpl {
  ServicesRepositoryImpl(this._dataSource);

  final ServicesRemoteDataSource _dataSource;

  Future<Either<Failure, List<ServiceEntity>>> listServices(String spId) async {
    try {
      final models = await _dataSource.listServices(spId);
      return right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  Future<Either<Failure, ServiceEntity>> createService(
    String spId,
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await _dataSource.createService(spId, data);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  Future<Either<Failure, ServiceEntity>> updateService(
    String spId,
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await _dataSource.updateService(spId, serviceId, data);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  Future<Either<Failure, Unit>> deleteService(String spId, String serviceId) async {
    try {
      await _dataSource.deleteService(spId, serviceId);
      return right(unit);
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }
}

extension _ServiceModelMapper on ServiceModel {
  ServiceEntity toEntity() => ServiceEntity(
        id: id,
        serviceProviderId: serviceProviderId,
        businessId: businessId,
        name: name,
        durationMinutes: durationMinutes,
        price: price,
        availableDays: availableDays,
        timeRanges: timeRanges
            .map((tr) => TimeRangeEntity(day: tr.day, start: tr.start, end: tr.end))
            .toList(),
        notes: notes,
        image: image,
        icon: icon,
        isActive: isActive,
      );
}
