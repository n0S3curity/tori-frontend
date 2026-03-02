import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/businesses_repository.dart';

class JoinBusinessUseCase {
  JoinBusinessUseCase(this._repository);

  final BusinessesRepository _repository;

  Future<Either<Failure, Unit>> call(String businessId) =>
      _repository.requestRegistration(businessId);
}
