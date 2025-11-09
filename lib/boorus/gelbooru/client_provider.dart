// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers.dart';

final gelbooruClientProvider = Provider.family<GelbooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(gelbooruDioProvider(config));

    return GelbooruClient.custom(
      baseUrl: config.url,
      login: config.login,
      apiKey: config.apiKey,
      passHash: config.passHash,
      dio: dio,
    );
  },
);

final gelbooruDioProvider = Provider.family<Dio, BooruConfigAuth>((
  ref,
  config,
) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassProvider);
  final loggerService = ref.watch(loggerProvider);

  return newDio(
    options: DioOptions(
      ddosProtectionHandler: ddosProtectionHandler,
      userAgent: ref.watch(defaultUserAgentProvider),
      loggerService: loggerService,
      networkProtocolInfo: ref.watch(
        defaultNetworkProtocolInfoProvider(config),
      ),
      baseUrl: config.url,
      proxySettings: config.proxySettings,
    ),
    additionalInterceptors: [
      const PaginationLimitErrorInterceptor(
        detectionString: 'Too deep! Pull it back some',
        detectionStatusCode: 200,
        returnedStatusCode: 410,
      ),
      ref.watch(defaultSlidingWindowRateLimitConfigInterceptorProvider),
    ],
  );
});
