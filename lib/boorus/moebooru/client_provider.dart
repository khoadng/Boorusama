// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers.dart';
import 'moebooru.dart';

final moebooruClientProvider = Provider.family<MoebooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));
    final postRequestDio = ref.watch(moebooruPostRequestDioProvider(config));
    final moebooru = ref.watch(moebooruProvider);

    return MoebooruClient.custom(
      baseUrl: config.url,
      login: config.login,
      apiKey: config.apiKey,
      dio: dio,
      postRequestDio: postRequestDio,
      version: switch (moebooru.getVersion(config.url)) {
        null => null,
        final v => Version.tryParse(v),
      },
    );
  },
);

final moebooruPostRequestDioProvider = Provider.family<Dio?, BooruConfigAuth>((
  ref,
  config,
) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassProvider);
  final loggerService = ref.watch(loggerProvider);
  final moebooru = ref.watch(moebooruProvider);

  return switch (moebooru.getPostRequestUrl(config.url)) {
    null => null,
    final postRequestUrl => newDio(
      options: DioOptions(
        ddosProtectionHandler: ddosProtectionHandler,
        userAgent: ref.watch(defaultUserAgentProvider),
        loggerService: loggerService,
        networkProtocolInfo: ref.watch(
          defaultNetworkProtocolInfoProvider(config),
        ),
        baseUrl: postRequestUrl,
        proxySettings: config.proxySettings,
      ),
      additionalInterceptors: [
        ref.watch(defaultSlidingWindowRateLimitConfigInterceptorProvider),
      ],
    ),
  };
});
