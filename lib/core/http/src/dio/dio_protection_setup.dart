// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../../../ddos_solver/protection_detector.dart';
import '../../../ddos_solver/protection_handler.dart';
import '../../../ddos_solver/protection_orchestrator.dart';
import '../../../ddos_solver/protection_solver.dart';
import '../../../ddos_solver/user_agent_provider.dart';
import 'dio_protection_interceptor.dart';

DioProtectionInterceptor createInterceptor({
  required CookieJar cookieJar,
  required BuildContext Function() contextProvider,
  required Dio dio,
}) {
  final userAgentProvider = WebViewUserAgentProvider();

  return DioProtectionInterceptor(
    protectionHandler: HttpProtectionHandler(
      orchestrator: ProtectionOrchestrator(
        userAgentProvider: userAgentProvider,
        detectors: [
          CloudflareDetector(),
          McChallengeDetector(),
          AftDetector(),
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
          AftSolver(
            contextProvider: contextProvider,
            cookieJar: cookieJar,
          ),
        ],
      ),
      contextProvider: contextProvider,
      cookieJar: cookieJar,
      userAgentProvider: userAgentProvider,
    ),
    dio: dio,
  );
}
