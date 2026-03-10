// services/service_locator.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServices() {
  // You need to set this after user login
  // getIt.registerLazySingleton(() => PropertyService(userId: 'current_user_id'));
}