// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class WebViewUserAgentService {
  Future<String?> getUserAgent();
}

final webViewUserAgentServiceProvider = Provider<WebViewUserAgentService>(
  (_) => throw UnimplementedError(
    'webViewUserAgentServiceProvider must be overridden',
  ),
);
