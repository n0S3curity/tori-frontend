import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/business_entity.dart';
import '../entities/user_entity.dart';

abstract class BusinessesRepository {
  Future<Either<Failure, List<BusinessEntity>>> listBusinesses();
  Future<Either<Failure, BusinessEntity>> getBusiness(String id);
  Future<Either<Failure, BusinessEntity>> createBusiness(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> requestRegistration(String businessId);
  Future<Either<Failure, List<UserEntity>>> listPendingRegistrations(String businessId);
  Future<Either<Failure, Unit>> approveRegistration(String businessId, String userId);
  Future<Either<Failure, Unit>> rejectRegistration(String businessId, String userId);
}
