import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:agentic_ai/app/core/errors/failures.dart';
import 'package:agentic_ai/app/core/usecases/usecase.dart';
import 'package:agentic_ai/app/features/authentication/domain/entities/user.dart';
import 'package:agentic_ai/app/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUser implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.registerWithEmail(params.email, params.password);
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;

  const RegisterParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
