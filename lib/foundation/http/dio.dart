// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/router.dart';
import 'cloudflare_challenge_interceptor.dart';
import 'dio_logger_interceptor.dart';
import 'http_utils.dart';

// Some user might input the url with /index.php/ or /index.php so we need to clean it
String _cleanUrl(String url) {
  // if /index.php/ or /index.php is present, remove it
  if (url.endsWith('/index.php/')) {
    return url.replaceAll('/index.php/', '/');
  } else if (url.endsWith('/index.php')) {
    return url.replaceAll('/index.php', '/');
  } else {
    return url;
  }
}

Dio newDio({required DioOptions options}) {
  final booruConfig = options.authConfig;
  final dir = options.cacheDir;
  final logger = options.loggerService;
  final userAgent = options.userAgent;
  final baseUrl = options.baseUrl;
  final booruFactory = options.booruFactory;

  final booru = booruFactory.getBooruFromUrl(baseUrl) ??
      booruFactory.getBooruFromId(booruConfig.booruId);
  final supportsHttp2 =
      booru?.getSiteProtocol(baseUrl) == NetworkProtocol.https_2_0;
  final apiUrl = booru?.getApiUrl(baseUrl) ?? baseUrl;

  final context = navigatorKey.currentContext;

  final dio = Dio(BaseOptions(
    // This is a hack to clean the url, if there are more sites that need this we should refactor this into something more generic
    baseUrl: _cleanUrl(apiUrl),
    headers: {
      AppHttpHeaders.userAgentHeader: userAgent,
    },
  ));

  // NativeAdapter only does something on Android and iOS/MacOS
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    dio.httpClientAdapter = newNativeAdapter(
      userAgent: userAgent,
    );
  } else if (supportsHttp2) {
    dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 30),
      ),
    );
  }

  dio.interceptors.add(
    DioCacheInterceptor(
      options: CacheOptions(
        store: HiveCacheStore(dir.path),
        maxStale: const Duration(days: 7),
        hitCacheOnErrorExcept: [403, 401],
      ),
    ),
  );

  if (context != null) {
    dio.interceptors.add(
      CloudflareChallengeInterceptor(
        storagePath: options.cacheDir.path,
        context: context,
      ),
    );
  }

  dio.interceptors.add(
    LoggingInterceptor(
      logger: logger,
    ),
  );

  return dio;
}

NativeAdapter newNativeAdapter({String? userAgent}) {
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
              URLRequestCachePolicy.reloadIgnoringLocalCacheData
          // We have our own cookie handling with CF
          ..httpShouldSetCookies = false,
  );
}

class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = ''
      ..idleTimeout = const Duration(seconds: 30);
  }
}
