import 'package:dio/dio.dart';

import 'app_constants.dart';

class ApiClient {
  ApiClient._();

  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
      ),
    );
  }
}
