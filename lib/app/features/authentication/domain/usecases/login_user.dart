import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:agentic_ai/app/core/errors/failures.dart';
import 'package:agentic_ai/app/core/usecases/usecase.dart';
import 'package:agentic_ai/app/features/authentication/domain/entities/user.dart';
import 'package:agentic_ai/app/features/authentication/domain/repositories/auth_repository.dart';

class LoginUser implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.loginWithEmail(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
