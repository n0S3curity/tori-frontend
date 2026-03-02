import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  GoogleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, ({UserEntity user, String token})>> call({
    required String role,
    String? businessName,
  }) =>
      _repository.googleLogin(role: role, businessName: businessName);
}
