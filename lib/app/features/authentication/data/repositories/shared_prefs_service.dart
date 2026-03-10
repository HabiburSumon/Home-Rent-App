import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_response_model.dart';
import '../models/user_model.dart';


class SharedPrefsService {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user data (store individual fields for simplicity)
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_userIdKey, user.id.toString()),
      prefs.setString(_userNameKey, user.name.toString()),
      prefs.setString(_userEmailKey, user.email.toString()),
      prefs.setString(_userPhoneKey, user.phone.toString()),
    ]);
  }

  // Get user data
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getString(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);
    final phone = prefs.getString(_userPhoneKey);

    if (id != null && name != null && email != null && phone != null) {
      return User(
        id: id,
        name: name,
        email: email,
        phone: phone,
      );
    }

    return null;
  }

  // Set login status
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_isLoggedInKey);
  }

  // Get user name (quick access)
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Get user email (quick access)
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
}