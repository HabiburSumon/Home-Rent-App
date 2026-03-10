// Since signup returns the same structure as login, we can reuse LoginResponse
// But let's check the structure first
import 'login_response_model.dart';

class SignupResponse {
  final bool success;
  final String message;
  final SignupData data;

  SignupResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'An unknown error occurred',
      data: SignupData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class SignupData {
  final User user;
  final String token;

  SignupData({
    required this.user,
    required this.token,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}

// Note: Structure is different:
// Login: {"data": {"token": "...", "user": {...}}}
// Signup: {"data": {"user": {...}, "token": "..."}}