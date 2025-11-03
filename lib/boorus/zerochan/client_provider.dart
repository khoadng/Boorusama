// Package imports:
import 'package:booru_clients/zerochan.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/info/app_info.dart';
import '../../foundation/info/package_info.dart';
import '../../foundation/loggers.dart';

final zerochanClientProvider = Provider.family<ZerochanClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(zerochanDioProvider(config));
    final logger = ref.watch(loggerProvider);

    return ZerochanClient(
      dio: dio,
      logger: (message) => logger.error('ZerochanClient', message),
    );
  },
);

final zerochanDioProvider = Provider.family<Dio, BooruConfigAuth>((
  ref,
  config,
) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassProvider);
  final appVersion = ref.watch(packageInfoProvider).version;
  final appName = ref.watch(appInfoProvider).appName;
  final loggerService = ref.watch(loggerProvider);

  return newDio(
    options: DioOptions(
      ddosProtectionHandler: ddosProtectionHandler,
      userAgent: '${appName.sentenceCase}/$appVersion - boorusama',
      loggerService: loggerService,
      networkProtocolInfo: ref.watch(
        defaultNetworkProtocolInfoProvider(config),
      ),
      baseUrl: config.url,
      proxySettings: config.proxySettings,
    ),
    additionalInterceptors: [
      // 55 requests per minute (conservative buffer below 60 to avoid hitting limits)
      SlidingWindowRateLimitInterceptor(
        config: const SlidingWindowRateLimitConfig(
          requestsPerWindow: 55,
          windowSizeMs: 60000,
          maxDelayMs: 10000,
        ),
      ),
    ],
  );
});
