import 'package:dartz/dartz.dart';

import 'package:agentic_ai/app/core/errors/failures.dart';
import 'package:agentic_ai/app/core/usecases/usecase.dart';
import 'package:agentic_ai/app/features/authentication/domain/repositories/auth_repository.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
