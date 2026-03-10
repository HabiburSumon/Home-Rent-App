import 'dart:convert';
import 'package:agentic_ai/app/features/authentication/data/repositories/shared_prefs_service.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../models/profile_model.dart';

class ProfileService {
  // Get user profile
  static Future<ProfileResponse> getProfile() async {
    try {
      final token = await SharedPrefsService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(AppConfig.profileUrl),
        headers: AppConfig.headersWithToken(token),
      ).timeout(const Duration(seconds: 30));

      if (AppConfig.debugMode) {
        print('Profile Response Status: ${response.statusCode}');
        print('Profile Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ProfileResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to load profile');
        } catch (_) {
          throw Exception('Failed to load profile. Status: ${response.statusCode}');
        }
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<ProfileResponse> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await SharedPrefsService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse(AppConfig.profileUrl),
        headers: AppConfig.headersWithToken(token),
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
        }),
      ).timeout(const Duration(seconds: 30));

      if (AppConfig.debugMode) {
        print('Update Profile Response Status: ${response.statusCode}');
        print('Update Profile Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ProfileResponse.fromJson(responseData);
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to update profile');
        } catch (_) {
          throw Exception('Failed to update profile. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await SharedPrefsService.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/profile/change-password'),
        headers: AppConfig.headersWithToken(token),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 30));

      if (AppConfig.debugMode) {
        print('Change Password Response Status: ${response.statusCode}');
        print('Change Password Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] as bool? ?? false;
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to change password');
        } catch (_) {
          throw Exception('Failed to change password. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}