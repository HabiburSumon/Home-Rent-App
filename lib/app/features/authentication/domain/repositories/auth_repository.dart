import 'package:dartz/dartz.dart';

import 'package:agentic_ai/app/core/errors/failures.dart';
import 'package:agentic_ai/app/features/authentication/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithEmail(String email, String password);
  Future<Either<Failure, User>> registerWithEmail(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getLoggedInUser();
}
