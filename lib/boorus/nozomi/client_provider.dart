// Package imports:
import 'package:booru_clients/nozomi.dart';
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

final nozomiClientProvider = Provider.family<NozomiClient, BooruConfigAuth>((
  ref,
  config,
) {
  final dio = ref.watch(nozomiDioProvider(config));
  final logger = ref.watch(loggerProvider);

  return NozomiClient(
    dio: dio,
    logger: (message) => logger.error('NozomiClient', message),
  );
});

final nozomiDioProvider = Provider.family<Dio, BooruConfigAuth>((ref, config) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassProvider);
  final appVersion = ref.watch(packageInfoProvider).version;
  final appName = ref.watch(appInfoProvider).appName;
  final loggerService = ref.watch(loggerProvider);

  final dio = newDio(
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
  );

  dio.options.headers['Origin'] = 'https://nozomi.la';
  dio.options.headers['Referer'] = 'https://nozomi.la/';

  return dio;
});
