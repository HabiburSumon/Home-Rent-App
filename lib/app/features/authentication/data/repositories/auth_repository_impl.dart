import 'dart:convert';

import 'package:dartz/dartz.dart';

import 'package:agentic_ai/app/core/errors/exceptions.dart';
import 'package:agentic_ai/app/core/errors/failures.dart';
import 'package:agentic_ai/app/core/network/network_info.dart';
import 'package:agentic_ai/app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:agentic_ai/app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:agentic_ai/app/features/authentication/data/models/user_model.dart';
import 'package:agentic_ai/app/features/authentication/domain/entities/user.dart';
import 'package:agentic_ai/app/features/authentication/domain/repositories/auth_repository.dart';

typedef _ConcreteCall = Future<UserModel> Function();

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> loginWithEmail(String email, String password) async {
    return await _getAuth(() => remoteDataSource.loginWithEmail(email, password));
  }

  @override
  Future<Either<Failure, User>> registerWithEmail(String email, String password) async {
    return await _getAuth(() => remoteDataSource.registerWithEmail(email, password));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.logout();
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getLoggedInUser() async {
    try {
      final jsonString = await localDataSource.getLastUser();
      return Right(UserModel.fromJson(json.decode(jsonString)));
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, User>> _getAuth(_ConcreteCall concreteCall) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await concreteCall();
        localDataSource.cacheUser(json.encode(remoteUser.toJson()));
        return Right(remoteUser);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
