// Package imports:
import 'package:booru_clients/zerochan.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/http/http.dart';
import '../../core/http/providers.dart';
import '../../foundation/info/app_info.dart';
import '../../foundation/info/package_info.dart';
import '../../foundation/loggers.dart';
import '../../foundation/vendors/google/providers.dart';

final zerochanClientProvider = Provider.family<ZerochanClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(zerochanDioProvider(config));
    final logger = ref.watch(loggerProvider);

    return ZerochanClient(
      dio: dio,
      logger: (message) => logger.logE('ZerochanClient', message),
    );
  },
);

final zerochanDioProvider = Provider.family<Dio, BooruConfigAuth>((
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
  );
});
