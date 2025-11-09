// Package imports:
import 'package:booru_clients/core.dart';
import 'package:booru_clients/gelbooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers.dart';
import 'gelbooru_v2_provider.dart';

final gelbooruV2ClientProvider =
    Provider.family<GelbooruV2Client, BooruConfigAuth>((ref, config) {
      final dio = ref.watch(gelbooruV2DioProvider(config));
      final gelbooruV2 = ref.watch(gelbooruV2Provider);
      final capabilities = gelbooruV2.getCapabilitiesForSite(config.url);
      final postsCapabilities = capabilities?.posts;

      return GelbooruV2Client(
        baseUrl: config.url,
        userId: config.login,
        apiKey: config.apiKey,
        passHash: config.passHash,
        dio: dio,
        paginationType: PaginationType.parse(postsCapabilities?.paginationType),
        fixedLimit: switch (postsCapabilities?.fixedLimit) {
          final int n => n,
          _ => null,
        },
        config: gelbooruV2.buildClientConfig(
          baseConfig: GelbooruV2Client.defaultEndpoints(
            globalUserParams: gelbooruV2.getGlobalUserParams(),
          ),
          siteUrl: config.url,
          parserResolver: ParserRegistry.resolve,
        ),
      );
    });

final gelbooruV2DioProvider = Provider.family<Dio, BooruConfigAuth>((
  ref,
  config,
) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassProvider);
  final loggerService = ref.watch(loggerProvider);
  final gelbooruV2 = ref.watch(gelbooruV2Provider);
  final capabilities = gelbooruV2.getCapabilitiesForSite(config.url);

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
      if (capabilities?.auth?.cookie case final c?)
        if (c.isNotEmpty) CookieInjectionInterceptor(cookie: c),
      if (capabilities?.auth?.required case true)
        AuthErrorResponseInterceptor(),
      ref.watch(defaultSlidingWindowRateLimitConfigInterceptorProvider),
    ],
  );
});
