// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/info/app_info.dart';
import '../../foundation/info/package_info.dart';
import '../../foundation/loggers.dart';
import '../../foundation/vendors/google/providers.dart';

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
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassHandler);
  final appVersion = ref.watch(packageInfoProvider).version;
  final appName = ref.watch(appInfoProvider).appName;
  final loggerService = ref.watch(loggerProvider);
  final booruDb = ref.watch(booruDbProvider);
  final cronetAvailable = ref.watch(isGooglePlayServiceAvailableProvider);

  return newDio(
    options: DioOptions(
      ddosProtectionHandler: ddosProtectionHandler,
      userAgent: '${appName.sentenceCase}/$appVersion - boorusama',
      authConfig: config,
      loggerService: loggerService,
      booruDb: booruDb,
      cronetAvailable: cronetAvailable,
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
