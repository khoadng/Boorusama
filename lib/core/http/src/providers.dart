// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../boorus/booru/booru.dart';
import '../../boorus/booru/providers.dart';
import '../../configs/config.dart';
import '../../ddos_solver/protection_detector.dart';
import '../../ddos_solver/protection_handler.dart';
import '../../ddos_solver/protection_orchestrator.dart';
import '../../ddos_solver/protection_solver.dart';
import '../../ddos_solver/user_agent_provider.dart';
import '../../foundation/loggers.dart';
import '../../google/providers.dart';
import '../../info/app_info.dart';
import '../../info/package_info.dart';
import '../../router.dart';
import 'cookie_jar_providers.dart';
import 'dio/dio.dart';
import 'dio/dio_options.dart';

final dioProvider = Provider.family<Dio, BooruConfigAuth>((ref, config) {
  final ddosProtectionHandler = ref.watch(httpDdosProtectionBypassHandler);
  final userAgent = ref.watch(userAgentProvider(config.booruType));
  final loggerService = ref.watch(loggerProvider);
  final booruDb = ref.watch(booruDbProvider);
  final cronetAvailable = ref.watch(isGooglePlayServiceAvailableProvider);

  return newDio(
    options: DioOptions(
      ddosProtectionHandler: ddosProtectionHandler,
      baseUrl: config.url,
      userAgent: userAgent,
      authConfig: config,
      loggerService: loggerService,
      booruDb: booruDb,
      proxySettings: config.proxySettings,
      cronetAvailable: cronetAvailable,
    ),
  );
});

final userAgentProvider = Provider.family<String, BooruType>(
  (ref, booruType) {
    final appVersion = ref.watch(packageInfoProvider).version;
    final appName = ref.watch(appInfoProvider).appName;

    return switch (booruType) {
      BooruType.zerochan => '${appName.sentenceCase}/$appVersion - boorusama',
      _ => '${appName.sentenceCase}/$appVersion',
    };
  },
);

final httpDdosProtectionBypassHandler = Provider<HttpProtectionHandler>(
  (ref) {
    final cookieJar = ref.watch(cookieJarProvider);
    BuildContext? contextProvider() {
      final context = navigatorKey.currentContext;

      return context;
    }

    return HttpProtectionHandler(
      orchestrator: ProtectionOrchestrator(
        userAgentProvider: WebViewUserAgentProvider(),
        detectors: [
          CloudflareDetector(),
          McChallengeDetector(),
          AftV2Detector(),
        ],
        solvers: [
          CloudflareSolver(
            contextProvider: contextProvider,
            cookieJar: cookieJar,
          ),
          McChallengeSolver(
            contextProvider: contextProvider,
            cookieJar: cookieJar,
          ),
          AftV2Solver(
            contextProvider: contextProvider,
            cookieJar: cookieJar,
          ),
        ],
      ),
      contextProvider: contextProvider,
      cookieJar: cookieJar,
    );
  },
);

final httpCacheDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(),
  name: 'httpCacheDirProvider',
);
