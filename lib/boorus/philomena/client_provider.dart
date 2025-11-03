// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers/providers.dart';

final philomenaClientProvider =
    Provider.family<PhilomenaClient, BooruConfigAuth>(
      (ref, config) {
        final dio = ref.watch(philomenaDioProvider(config));

        return PhilomenaClient(
          dio: dio,
          baseUrl: config.url,
          apiKey: config.apiKey,
        );
      },
    );

final philomenaDioProvider = Provider.family<Dio, BooruConfigAuth>((
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
      PhilomenaRateLimitInterceptor(),
    ],
  );
});
