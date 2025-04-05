// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'protection_detector.dart';
import 'protection_interceptor.dart';
import 'protection_orchestrator.dart';
import 'protection_solver.dart';

ProtectionInterceptor createInterceptor({
  required CookieJar cookieJar,
  required BuildContext Function() contextProvider,
  required Dio dio,
}) {
  final userAgentProvider = UserAgentProvider();

  return ProtectionInterceptor(
    cookieJar: cookieJar,
    userAgentProvider: userAgentProvider,
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
    dio: dio,
  );
}

class UserAgentProvider {
  String? _userAgent;

  Future<String?> getUserAgent() async {
    if (_userAgent != null) {
      return _userAgent;
    }

    // ignore: join_return_with_assignment
    _userAgent ??= await WebViewController().getUserAgent();

    return _userAgent;
  }
}
