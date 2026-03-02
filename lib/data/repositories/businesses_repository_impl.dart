import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/business_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/businesses_repository.dart';
import '../datasources/remote/businesses_remote_datasource.dart';
import '../models/business_model.dart';
import '../models/user_model.dart';

class BusinessesRepositoryImpl implements BusinessesRepository {
  BusinessesRepositoryImpl(this._dataSource);

  final BusinessesRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<BusinessEntity>>> listBusinesses() async {
    try {
      final models = await _dataSource.listBusinesses();
      return right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, BusinessEntity>> getBusiness(String id) async {
    try {
      final model = await _dataSource.getBusiness(id);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, BusinessEntity>> createBusiness(Map<String, dynamic> data) async {
    try {
      final model = await _dataSource.createBusiness(data);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, Unit>> requestRegistration(String businessId) async {
    try {
      await _dataSource.requestRegistration(businessId);
      return right(unit);
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> listPendingRegistrations(String businessId) async {
    try {
      final models = await _dataSource.listPendingRegistrations(businessId);
      return right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, Unit>> approveRegistration(String businessId, String userId) async {
    try {
      await _dataSource.approveRegistration(businessId, userId);
      return right(unit);
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectRegistration(String businessId, String userId) async {
    try {
      await _dataSource.rejectRegistration(businessId, userId);
      return right(unit);
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }
}

extension _BusinessModelMapper on BusinessModel {
  BusinessEntity toEntity() => BusinessEntity(
        id: id,
        name: name,
        logo: logo,
        ownerId: ownerId,
        isDisabled: isDisabled,
        usersDisabled: usersDisabled,
        remindersEnabled: remindersEnabled,
        formattedAddress: address?.formatted,
        lat: address?.lat,
        lng: address?.lng,
      );
}

extension _UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        phoneVerified: phoneVerified,
        profileImage: profileImage,
        role: role,
        language: language,
        isDisabled: isDisabled,
      );
}
