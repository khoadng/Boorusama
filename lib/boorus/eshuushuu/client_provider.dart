// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/data.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/manage/providers.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers.dart';
import 'auth/auth_interceptor.dart';

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

  final refreshToken = config.apiKey;

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
      SlidingWindowRateLimitInterceptor(
        config: const SlidingWindowRateLimitConfig(
          requestsPerWindow: 30,
          windowSizeMs: 60000,
          maxDelayMs: 10000,
        ),
      ),
      if (refreshToken != null && refreshToken.isNotEmpty)
        createEshuushuuAuthInterceptor(
          refreshToken: refreshToken,
          baseUrl: config.url,
          onTokenRefreshed: (tokens) {
            final currentConfig = ref
                .read(booruConfigProvider)
                .firstWhereOrNull((c) => c.auth == config);
            if (currentConfig != null) {
              ref
                  .read(booruConfigRepoProvider)
                  .update(
                    currentConfig.id,
                    currentConfig
                        .copyWith(apiKey: tokens.refreshToken)
                        .toBooruConfigData(),
                  );
            }
          },
        ),
    ],
  );
});
