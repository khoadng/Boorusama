// Package imports:
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../proxy/client.dart';
import '../../../../proxy/types.dart';
import '../../../../router.dart';
import '../data/client.dart';
import '../interceptors/dio_image_deduplicate_interceptor.dart';
import '../interceptors/dio_logger_interceptor.dart';
import '../interceptors/dio_protection_interceptor.dart';
import '../types/dio_options.dart';
import '../types/http_adapter_config.dart';
import '../types/http_utils.dart';
import '../types/network_protocol_info.dart';

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
}) {
  final dio = newGenericDio(
    baseUrl: _cleanUrl(options.baseUrl),
    userAgent: options.userAgent,
    logger: options.loggerService,
    protocolInfo: options.networkProtocolInfo,
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
  final config = HttpAdapterConfig.fromContext(
    protocolInfo: protocolInfo,
    proxySettings: proxy,
    logger: logger,
    userAgent: userAgent,
  );

  return switch (config) {
    DefaultAdapterConfig(:final logger) => _createDefaultAdapter(logger),
    ProxyAdapterConfig(:final proxySettings, :final logger) =>
      _createProxyAdapter(proxySettings, logger),
    NativeAdapterConfig(:final userAgent, :final logger) =>
      _createNativeAdapter(userAgent, logger),
    Http2AdapterConfig(:final logger) => _createHttp2Adapter(logger),
  };
}

HttpClientAdapter _createDefaultAdapter(Logger? logger) {
  logger?.info('Network', 'Using default adapter');
  return HttpClientAdapter();
}

HttpClientAdapter _createProxyAdapter(
  ProxySettings proxySettings,
  Logger? logger,
) {
  logger?.info('Network', 'Using proxy adapter');
  return IOHttpClientAdapter(
    createHttpClient: () =>
        createProxyHttpClient(proxySettings, logger: logger),
  );
}

HttpClientAdapter _createNativeAdapter(String? userAgent, Logger? logger) {
  try {
    logger?.info('Network', 'Using native adapter');
    return newNativeAdapter(userAgent: userAgent);
  } catch (e) {
    logger?.warn(
      'Network',
      'Native adapter failed, falling back to default: $e',
    );
    return _createDefaultAdapter(logger);
  }
}

HttpClientAdapter _createHttp2Adapter(Logger? logger) {
  logger?.info('Network', 'Using HTTP2 adapter');
  return Http2Adapter(
    ConnectionManager(
      idleTimeout: const Duration(seconds: 30),
    ),
  );
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
