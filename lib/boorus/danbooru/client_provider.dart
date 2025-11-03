// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers/providers.dart';
import '../../foundation/vendors/google/providers.dart';

final danbooruClientProvider = Provider.family<DanbooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(danbooruDioProvider(config));

    return DanbooruClient(
      dio: dio,
      baseUrl: config.url,
      login: config.login,
      apiKey: config.apiKey,
    );
  },
);

final danbooruDioProvider = Provider.family<Dio, BooruConfigAuth>((
  ref,
  config,
) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassProvider);
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
      // 10 requests per second
      SlidingWindowRateLimitInterceptor(
        config: const SlidingWindowRateLimitConfig(
          requestsPerWindow: 10,
          windowSizeMs: 1000,
        ),
      ),
    ],
  );
});
