// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers/providers.dart';
import '../../foundation/platform.dart';

final danbooruClientProvider = Provider.family<DanbooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(danbooruDioProvider(config));

    return DanbooruClient(
      dio: dio,
      baseUrl: config.url,
      login: isWeb() ? null : config.login,
      apiKey: isWeb() ? null : config.apiKey,
    );
  },
);

final danbooruDioProvider = Provider.family<Dio, BooruConfigAuth>((
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
      ref.watch(defaultSlidingWindowRateLimitConfigInterceptorProvider),
      // Use query parameters for auth on web to avoid CORS preflight
      if (isWeb())
        if ((config.login, config.apiKey) case (
          final login?,
          final apiKey?,
        ))
          DanbooruAuthInterceptor(
            login: login,
            apiKey: apiKey,
          ),
    ],
  );
});
