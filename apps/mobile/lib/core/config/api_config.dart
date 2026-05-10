import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }

    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
      return '${Uri.base.scheme}://$host:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }
}
