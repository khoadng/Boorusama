// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

// Project imports:
import 'winhttp_dio_adapter.dart';

HttpClientAdapter newNativeAdapter({String? userAgent}) {
  return NativeAdapter(
    createCronetEngine: () => CronetEngine.build(
      // We have our own cache interceptor
      cacheMode: CacheMode.disabled,
      enableBrotli: true,
      enableHttp2: true,
      enableQuic: true,
      userAgent: userAgent,
    ),
    createCupertinoConfiguration: () =>
        URLSessionConfiguration.ephemeralSessionConfiguration()
          // We have our own cache interceptor
          ..requestCachePolicy =
              NSURLRequestCachePolicy.NSURLRequestReloadIgnoringLocalCacheData
          // We have our own cookie handling with CF
          ..httpShouldSetCookies = false,
  );
}

HttpClientAdapter newWinHttpAdapter({String? userAgent}) =>
    WinHttpDioAdapter(userAgent: userAgent);

class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = ''
      ..idleTimeout = const Duration(seconds: 30);
  }
}

void setupHttpOverrides() {
  HttpOverrides.global = AppHttpOverrides();
}
