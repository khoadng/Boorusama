// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/http/http.dart';
import '../../core/http/providers.dart';
import '../../foundation/info/app_info.dart';
import '../../foundation/info/package_info.dart';
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
  final packageInfo = ref.watch(packageInfoProvider);
  final appInfo = ref.watch(appInfoProvider);
  final loggerService = ref.watch(loggerProvider);
  final booruDb = ref.watch(booruDbProvider);
  final cronetAvailable = ref.watch(isGooglePlayServiceAvailableProvider);

  return newDio(
    options: DioOptions(
      ddosProtectionHandler: ddosProtectionHandler,
      userAgent: getDefaultUserAgent(appInfo, packageInfo),
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
