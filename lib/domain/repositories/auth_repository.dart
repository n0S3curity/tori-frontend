import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, ({UserEntity user, String token})>> googleLogin({
    required String role,
    String? businessName,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String sessionInfo,
    required String code,
  });
}
