import 'package:dartz/dartz.dart';

import 'package:agentic_ai/app/core/errors/failures.dart';
import 'package:agentic_ai/app/core/usecases/usecase.dart';
import 'package:agentic_ai/app/features/authentication/domain/entities/user.dart';
import 'package:agentic_ai/app/features/authentication/domain/repositories/auth_repository.dart';

class GetLoggedInUser implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GetLoggedInUser(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getLoggedInUser();
  }
}
