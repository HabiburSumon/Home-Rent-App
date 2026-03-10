import 'package:flutter/material.dart';

class AppConfig {
  // API Base URL - Change this to your actual server IP/URL
  static const String baseUrl = 'http://172.17.15.102:3000/api';

  // Alternatively, for physical device testing with Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  // For physical device testing with iOS simulator:
  // static const String baseUrl = 'http://localhost:3000/api';

  // For physical device testing (phone connected to same network):
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';

  // API Endpoints
  static String get loginUrl => '$baseUrl/auth/login';
  static String get signupUrl => '$baseUrl/auth/signup';
  static String get profileUrl => '$baseUrl/profile';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add token to headers
  static Map<String, String> headersWithToken(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Debug mode
  static const bool debugMode = true;
}