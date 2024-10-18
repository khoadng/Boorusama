// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/router.dart';
import 'cloudflare_challenge_interceptor.dart';

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

Dio newDio(
  DioArgs args,
) {
  final booruConfig = args.booruConfig;
  final dir = args.cacheDir;
  final logger = args.loggerService;
  final generator = args.userAgentGenerator;
  final baseUrl = args.baseUrl;
  final booruFactory = args.booruFactory;

  final booru = booruFactory.getBooruFromUrl(baseUrl);
  final supportsHttp2 =
      booru?.getSiteProtocol(baseUrl) == NetworkProtocol.https_2_0;
  final apiUrl = booru?.getApiUrl(baseUrl) ?? baseUrl;

  final context = navigatorKey.currentContext;

  final dio = Dio(BaseOptions(
    // This is a hack to clean the url, if there are more sites that need this we should refactor this into something more generic
    baseUrl: _cleanUrl(apiUrl),
    headers: {
      AppHttpHeaders.userAgentHeader: generator.generate(),
    },
  ));

  if (supportsHttp2) {
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
        storagePath: args.cacheDir.path,
        context: context,
      ),
    );
  }

  dio.interceptors.add(
    LoggingInterceptor(
      logger: logger,
      booruConfig: booruConfig,
    ),
  );

  return dio;
}

class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..idleTimeout = const Duration(seconds: 30);
  }
}
