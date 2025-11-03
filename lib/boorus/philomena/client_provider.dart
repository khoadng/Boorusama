// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';
import '../../core/http/types.dart';
import '../../foundation/loggers/providers.dart';
import '../../foundation/vendors/google/providers.dart';

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
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassHandler);
  final loggerService = ref.watch(loggerProvider);
  final booruDb = ref.watch(booruDbProvider);
  final cronetAvailable = ref.watch(isGooglePlayServiceAvailableProvider);

  return newDio(
    options: DioOptions(
      ddosProtectionHandler: ddosProtectionHandler,
      userAgent: ref.watch(defaultUserAgentProvider),
      authConfig: config,
      loggerService: loggerService,
      booruDb: booruDb,
      cronetAvailable: cronetAvailable,
    ),
    additionalInterceptors: [
      PhilomenaRateLimitInterceptor(),
    ],
  );
});
