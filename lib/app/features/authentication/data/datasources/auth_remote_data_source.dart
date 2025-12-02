import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:agentic_ai/app/core/errors/exceptions.dart';
import 'package:agentic_ai/app/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test@example.com' && password == 'password') {
      return const UserModel(id: '1', email: 'test@example.com', name: 'Test User', role: 'renter');
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> registerWithEmail(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'new@example.com') {
      throw ServerException(message: 'Email already in use');
    } else {
      return const UserModel(id: '2', email: 'new@example.com', name: 'New User', role: 'renter');
    }
  }

  @override
  Future<void> logout() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return Future.value();
  }
}
