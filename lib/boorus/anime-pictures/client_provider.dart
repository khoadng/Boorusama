// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/configs/network/providers.dart';
import '../../core/ddos/handler/providers.dart';
import '../../core/http/client/providers.dart';
import '../../core/http/client/types.dart';
import '../../foundation/loggers.dart';

final animePicturesClientProvider =
    Provider.family<AnimePicturesClient, BooruConfigAuth>(
      (ref, config) {
        final dio = ref.watch(animePicturesDioProvider(config));

        return AnimePicturesClient(
          dio: dio,
          baseUrl: config.url,
          cookie: config.passHash,
        );
      },
    );

final animePicturesRateLimitInterceptorProvider =
    Provider<SlidingWindowRateLimitInterceptor>(
      (ref) => SlidingWindowRateLimitInterceptor(
        config: SlidingWindowRateLimitConfig(
          // Conservative app policy, shared across profiles and download flows.
          requestsPerWindow: 1,
          windowSizeMs: 1000,
          retryAfterFallback: const Duration(seconds: 30),
          // Download-link endpoints can end in image extensions.
          resolver: (_) => true,
        ),
      ),
    );

final animePicturesDioProvider = Provider.family<Dio, BooruConfigAuth>((
  ref,
  config,
) {
  return newDio(
    options: DioOptions(
      ddosProtectionHandler: ref.watch(httpDdosProtectionBypassProvider),
      userAgent: ref.watch(defaultUserAgentProvider),
      loggerService: ref.watch(loggerProvider),
      networkProtocolInfo: ref.watch(
        defaultNetworkProtocolInfoProvider(config),
      ),
      baseUrl: config.url,
      proxySettings: config.proxySettings,
      skipCertificateVerification:
          ref
              .watch(networkSettingsProvider(config))
              .httpSettings
              ?.skipCertificateVerification ??
          false,
    ),
    additionalInterceptors: [
      ref.watch(animePicturesRateLimitInterceptorProvider),
    ],
  );
});
