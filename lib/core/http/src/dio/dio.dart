// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/platform.dart';
import '../../../proxy/proxy.dart';
import '../../../router.dart';
import '../cloudflare_challenge_interceptor.dart';
import '../http_utils.dart';
import '../network_protocol.dart';
import 'dio_ext.dart';
import 'dio_logger_interceptor.dart';
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
  )..httpClientAdapter = _createHttpClientAdapter(
      logger: logger,
      userAgent: userAgent,
      supportsHttp2: supportsHttp2,
      proxy: options.proxySettings,
    );

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

HttpClientAdapter _createHttpClientAdapter({
  required Logger logger,
  required String userAgent,
  required bool supportsHttp2,
  ProxySettings? proxy,
}) {
  final proxySettings = proxy != null
      ? proxy.enable
          ? proxy
          : null
      : null;
  final proxyAddress = proxySettings?.getProxyAddress();

  if ((isAndroid() || isIOS() || isMacOS()) && proxySettings == null) {
    logger.logI('Network', 'Using native adapter');
    return newNativeAdapter(
      userAgent: userAgent,
    );
  } else if (supportsHttp2 && proxySettings == null) {
    logger.logI(
      'Network',
      'Using HTTP2 adapter',
    );

    return Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 30),
      ),
    );
  } else {
    logger.logI('Network', 'Using default adapter');
    return IOHttpClientAdapter(
      createHttpClient: proxySettings != null && proxyAddress != null
          ? () {
              final client = HttpClient();
              final username = proxySettings.username;
              final password = proxySettings.password;
              final port = proxySettings.port;
              final host = proxySettings.host;

              final credentials = username != null && password != null
                  ? HttpClientBasicCredentials(username, password)
                  : null;

              logger.logI(
                'Network',
                'Using proxy: ${proxySettings.type.name.toUpperCase()} $host:$port',
              );

              client
                ..badCertificateCallback = (cert, host, port) {
                  return true;
                }
                ..findProxy = (uri) {
                  final address = '$host:$port';

                  return 'PROXY $address';
                };

              if (credentials != null) {
                client.addProxyCredentials(host, port, 'main', credentials);
              }

              return client;
            }
          : null,
    );
  }
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
