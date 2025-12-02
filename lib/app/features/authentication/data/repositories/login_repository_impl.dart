import 'package:agentic_ai/app/features/authentication/data/datasources/api_service.dart';
import 'package:agentic_ai/app/features/authentication/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> login(String email, String password) async {
    await remoteDataSource.login(email, password);
  }
}
