// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/router.dart';
import 'cloudflare_challenge_interceptor.dart';

final cookieJarProvider = Provider<CookieJar>((ref) {
  final cacheDir = ref.watch(httpCacheDirProvider);

  return PersistCookieJar(
    storage: FileStorage(cacheDir.path),
  );
});

final bypassDdosHeadersProvider =
    FutureProvider.family<Map<String, String>, String>((ref, url) async {
  final cookieJar = ref.watch(cookieJarProvider);

  final cookies = await cookieJar.loadForRequest(Uri.parse(url));

  if (cookies.isEmpty) return const {};

  final cookieString = cookies.cookieString;

  final webviewController = WebViewController();
  final userAgent = await webviewController.getUserAgent();

  return {
    if (cookieString.isNotEmpty) 'cookie': cookieString,
    if (userAgent != null && userAgent.isNotEmpty) 'user-agent': userAgent,
  };
});

final cachedBypassDdosHeadersProvider =
    Provider.family<Map<String, String>, String>((ref, url) {
  final headers = ref.watch(bypassDdosHeadersProvider(url));

  return headers.maybeWhen(
    data: (value) => value,
    orElse: () => const {},
  );
});

// List of HTTP status codes where cached data should NOT be shown
const List<int> nonCacheableStatusCodes = [
  // Authentication and Authorization Errors
  401, // Unauthorized: User credentials are missing, invalid, or expired.
  403, // Forbidden: User doesn't have permission to access the resource.

  // Client-Side Errors
  400, // Bad Request: Malformed request (e.g., invalid query parameters).
  405, // Method Not Allowed: Invalid request method for the resource.
  406, // Not Acceptable: Response format incompatible with client's "Accept" header.

  // Server Errors Indicating Instability
  500, // Internal Server Error: Generic server error; data might be unreliable.
  502, // Bad Gateway: Intermediary issue (e.g., reverse proxy failure).
  503, // Service Unavailable: Temporary server unavailability (e.g., maintenance).
  504, // Gateway Timeout: Timeout while waiting for an upstream server.

  // Content Delivery Issues
  409, // Conflict: Conflicting changes to a resource (e.g., version control).
  417, // Expectation Failed: Failed "Expect" header condition.
  422, // Unprocessable Entity: Semantic issues with the request payload.

  // Legal and Rate Limiting Issues
  451, // Unavailable For Legal Reasons: Resource restricted due to legal policies.
];

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
        hitCacheOnErrorExcept: nonCacheableStatusCodes,
      ),
    ),
  );

  if (context != null) {
    dio.interceptors.add(
      CloudflareChallengeInterceptor(
        cookieJar: args.cookieJar,
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
      ..userAgent = ''
      ..idleTimeout = const Duration(seconds: 30);
  }
}
