// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers.dart';

final eshuushuuClientProvider =
    Provider.family<EShuushuuClient, BooruConfigAuth>(
      (ref, config) {
        final dio = ref.watch(eshuushuuDioProvider(config));

        return EShuushuuClient(
          dio: dio,
        );
      },
    );

final eshuushuuDioProvider = Provider.family<Dio, BooruConfigAuth>((
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
      // Conservative rate limiting
      SlidingWindowRateLimitInterceptor(
        config: const SlidingWindowRateLimitConfig(
          requestsPerWindow: 30,
          windowSizeMs: 60000,
          maxDelayMs: 10000,
        ),
      ),
    ],
  );
});
