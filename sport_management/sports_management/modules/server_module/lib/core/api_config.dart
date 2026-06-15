import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const String _localAndroidEmulatorBaseUrl =
      'http://10.0.2.2:3000/api/v1';
  static const String _productionBaseUrl =
      'FLUTTER_API_URL'; 

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kDebugMode ? _localAndroidEmulatorBaseUrl : _productionBaseUrl,
  );
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
