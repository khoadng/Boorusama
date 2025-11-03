// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:version/version.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers.dart';
import '../../foundation/vendors/google/providers.dart';
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
        final v => _tryParseVersion(v),
      },
    );
  },
);

final moebooruPostRequestDioProvider = Provider.family<Dio?, BooruConfigAuth>((
  ref,
  config,
) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassHandler);
  final loggerService = ref.watch(loggerProvider);
  final booruDb = ref.watch(booruDbProvider);
  final cronetAvailable = ref.watch(isGooglePlayServiceAvailableProvider);
  final moebooru = ref.watch(moebooruProvider);

  return switch (moebooru.getPostRequestUrl(config.url)) {
    null => null,
    final postRequestUrl => newDio(
      options: DioOptions(
        ddosProtectionHandler: ddosProtectionHandler,
        userAgent: ref.watch(defaultUserAgentProvider),
        authConfig: config,
        loggerService: loggerService,
        booruDb: booruDb,
        cronetAvailable: cronetAvailable,
        baseUrl: postRequestUrl,
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
    ),
  };
});

Version? _tryParseVersion(String versionString) {
  try {
    return Version.parse(versionString);
  } catch (_) {
    return null;
  }
}
