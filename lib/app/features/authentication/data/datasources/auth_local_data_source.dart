import 'package:shared_preferences/shared_preferences.dart';
import 'package:agentic_ai/app/core/errors/exceptions.dart';

const CACHED_USER = 'CACHED_USER';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(String userJson);
  Future<String> getLastUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(String userJson) {
    return sharedPreferences.setString(CACHED_USER, userJson);
  }

  @override
  Future<String> getLastUser() {
    final jsonString = sharedPreferences.getString(CACHED_USER);
    if (jsonString != null) {
      return Future.value(jsonString);
    } else {
      throw CacheException();
    }
  }
}
