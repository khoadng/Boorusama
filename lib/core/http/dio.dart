// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

// Project imports:
import '../../foundation/http.dart';
import '../../foundation/platform.dart';
import '../../router.dart';
import '../boorus.dart';
import 'dio_options.dart';

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

  final dio = Dio(
    BaseOptions(
      // This is a hack to clean the url, if there are more sites that need this we should refactor this into something more generic
      baseUrl: _cleanUrl(apiUrl),
      headers: {
        AppHttpHeaders.userAgentHeader: userAgent,
      },
    ),
  );

  // NativeAdapter only does something on Android and iOS/MacOS
  if (isAndroid() || isIOS() || isMacOS()) {
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
