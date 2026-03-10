import 'dart:convert';
import 'package:agentic_ai/app/features/authentication/data/models/user_model.dart' hide LoginResponse;
import 'package:agentic_ai/app/features/authentication/data/repositories/shared_prefs_service.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart' hide LoginResponse, User;


class AuthService {
  static Future<SignupResponse> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.signupUrl),
        headers: AppConfig.headers,
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (AppConfig.debugMode) {
        print('Signup Response Status: ${response.statusCode}');
        print('Signup Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response
        final Map<String, dynamic> responseData = json.decode(response.body);
        final signupResponse = SignupResponse.fromJson(responseData);

        // If signup includes auto-login, save the data
        if (signupResponse.success && signupResponse.data != null) {
          await _saveLoginDataFromSignup(signupResponse.data!);
        }

        return signupResponse;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Signup failed');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
  // Login method with automatic token saving
  static Future<LoginResponse> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.loginUrl),
        headers: AppConfig.headers,
        body: json.encode({
          'emailOrPhone': emailOrPhone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));
      print('login url ${AppConfig.loginUrl}');

      if (AppConfig.debugMode) {
        print('Login Response Status: ${response.statusCode}');
        print('Login Response Body: ${response.body}');
      }

      // Parse JSON response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Parse response
        final loginResponse = LoginResponse.fromJson(responseData);

        // Save token and user data automatically
        await _saveLoginData(loginResponse);

        return loginResponse;
      } else {
        // Handle non-200 responses
        final errorMessage = responseData['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _saveLoginDataFromSignup(SignupData signupData) async {
    await SharedPrefsService.saveToken(signupData.token);
    await SharedPrefsService.saveUser(signupData.user);
    await SharedPrefsService.setLoggedIn(true);

    if (AppConfig.debugMode) {
      print('Signup auto-login data saved');
    }
  }

  // Private method to save login data
  static Future<void> _saveLoginData(LoginResponse loginResponse) async {
    await SharedPrefsService.saveToken(loginResponse.data.token);
    await SharedPrefsService.setLoggedIn(true);
  }

  // Logout method
  static Future<void> logout() async {
    await SharedPrefsService.clearAll();

    if (AppConfig.debugMode) {
      print('User logged out, all data cleared');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await SharedPrefsService.isLoggedIn();
  }

  // Get stored token
  static Future<String?> getToken() async {
    return await SharedPrefsService.getToken();
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    return await SharedPrefsService.getUser();
  }

  // Refresh token (if needed)
  static Future<bool> refreshToken() async {
    // Implement token refresh logic here
    // This is useful when tokens expire
    return false;
  }
}