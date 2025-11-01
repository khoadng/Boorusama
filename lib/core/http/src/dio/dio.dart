// Dart imports:
import 'dart:io';

// Package imports:
import 'package:booru_clients/generated.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:socks5_proxy/socks.dart' as socks;

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../proxy/types.dart';
import '../../../router.dart';
import '../http_utils.dart';
import 'dio_ext.dart';
import 'dio_image_deduplicate_interceptor.dart';
import 'dio_logger_interceptor.dart';
import 'dio_options.dart';
import 'dio_protection_interceptor.dart';
import 'network_protocol_info.dart';

Dio newGenericDio({
  required String? baseUrl,
  String? userAgent,
  Logger? logger,
  NetworkProtocolInfo? protocolInfo,
  Map<String, dynamic>? headers,
  ProxySettings? proxySettings,
  List<Interceptor>? additionalInterceptors,
}) {
  final dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl ?? '',
            headers: {
              AppHttpHeaders.userAgentHeader: ?userAgent,
              ...?headers,
            },
          ),
        )
        ..httpClientAdapter = _createHttpClientAdapter(
          logger: logger,
          userAgent: userAgent,
          protocolInfo: protocolInfo,
          proxy: proxySettings,
        );

  dio.interceptors.add(ImageRequestDeduplicateInterceptor());

  if (logger != null) {
    dio.interceptors.add(
      LoggingInterceptor(
        logger: logger,
      ),
    );
  }

  additionalInterceptors?.forEach(dio.interceptors.add);

  return dio;
}

Dio newDio({
  required DioOptions options,
  List<Interceptor>? additionalInterceptors,
  NetworkProtocol? customProtocol,
}) {
  final booruConfig = options.authConfig;
  final booruDb = options.booruDb;
  final baseUrl = options.baseUrl;

  final booru =
      booruDb.getBooruFromUrl(baseUrl) ??
      booruDb.getBooruFromId(booruConfig.booruIdHint);
  final detectedProtocol = booru?.getSiteProtocol(baseUrl);

  final info = NetworkProtocolInfo(
    customProtocol: customProtocol,
    detectedProtocol: detectedProtocol,
    hasProxy: options.proxySettings?.enable ?? false,
    platform: PlatformInfo.fromCurrent(
      cronetAvailable: options.cronetAvailable,
    ),
  );

  final dio = newGenericDio(
    baseUrl: _cleanUrl(baseUrl),
    userAgent: options.userAgent,
    logger: options.loggerService,
    protocolInfo: info,
    proxySettings: options.proxySettings,
    additionalInterceptors: additionalInterceptors,
  );

  final context = navigatorKey.currentContext;
  if (context != null) {
    dio.interceptors.add(
      DioProtectionInterceptor(
        protectionHandler: options.ddosProtectionHandler,
        dio: dio,
      ),
    );
  }

  return dio;
}

HttpClientAdapter _createHttpClientAdapter({
  Logger? logger,
  String? userAgent,
  NetworkProtocolInfo? protocolInfo,
  ProxySettings? proxy,
}) {
  final proxySettings = proxy != null
      ? proxy.enable
            ? proxy
            : null
      : null;
  final proxyAddress = proxySettings?.getProxyAddress();

  HttpClientAdapter createDefaultAdapter() {
    logger?.info('Network', 'Using default adapter');
    return IOHttpClientAdapter(
      createHttpClient: proxySettings != null && proxyAddress != null
          ? () {
              final client = HttpClient();
              final username = proxySettings.username;
              final password = proxySettings.password;
              final port = proxySettings.port;
              final host = proxySettings.host;

              logger?.info(
                'Network',
                'Using proxy: ${proxySettings.type.name.toUpperCase()} $host:$port',
              );

              if (proxySettings.type == ProxyType.socks5) {
                socks.SocksTCPClient.assignToHttpClient(
                  client,
                  [
                    socks.ProxySettings(
                      InternetAddress(host),
                      port,
                      username: username,
                      password: password,
                    ),
                  ],
                );
              } else {
                final credentials = username != null && password != null
                    ? HttpClientBasicCredentials(username, password)
                    : null;

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
              }

              return client;
            }
          : null,
    );
  }

  HttpClientAdapter createNativeAdapter() {
    try {
      logger?.info('Network', 'Using native adapter');
      return newNativeAdapter(userAgent: userAgent);
    } catch (e) {
      logger?.warn(
        'Network',
        'Native adapter failed, falling back to default: $e',
      );
      return createDefaultAdapter();
    }
  }

  HttpClientAdapter createHttp2Adapter() {
    logger?.info('Network', 'Using HTTP2 adapter');
    return Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 30),
      ),
    );
  }

  final adapterType =
      protocolInfo?.getAdapterType() ?? HttpClientAdapterType.defaultAdapter;

  return switch (adapterType) {
    HttpClientAdapterType.http2 => createHttp2Adapter(),
    HttpClientAdapterType.nativeAdapter => createNativeAdapter(),
    HttpClientAdapterType.defaultAdapter => createDefaultAdapter(),
  };
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
