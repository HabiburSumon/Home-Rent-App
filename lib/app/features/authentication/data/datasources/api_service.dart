import 'package:dio/dio.dart';
import 'package:agentic_ai/app/features/authentication/data/models/login_response_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://172.17.15.102:3000/api';

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      print(response.data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (e.g., network issues, timeouts)
      throw Exception('Failed to login. Error: ${e.message}');
    } catch (e) {
      // Handle other potential errors
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}