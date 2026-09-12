// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../../http/cookies/providers.dart';
import '../../router.dart';
import '../solver/providers.dart';
import '../solver/types.dart';
import 'protection_handler.dart';

final httpDdosProtectionBypassProvider = Provider<HttpProtectionHandler>(
  (ref) {
    final cookieJar = ref.watch(cookieJarProvider);
    final logger = ref.watch(loggerProvider);
    BuildContext? contextProvider() {
      final context =
          navigatorKey.currentContext ?? navigatorKey.currentState?.context;

      return context;
    }

    return HttpProtectionHandler(
      orchestrator: ProtectionOrchestrator(
        userAgentProvider: WebViewUserAgentProvider(),
        detectors: [
          CloudflareDetector(),
          AftDetector(),
          CaptchaAccessDeniedDetector(),
        ],
        solvers: [
          CloudflareSolver(
            onLog: (message) => logger.info('Verification', message),
            contextProvider: contextProvider,
            cookieJar: cookieJar,
          ),
          AftSolver(
            onLog: (message) => logger.info('Verification', message),
            contextProvider: contextProvider,
            cookieJar: cookieJar,
          ),
          CaptchaAccessDeniedSolver(
            onLog: (message) => logger.info('Verification', message),
            contextProvider: contextProvider,
            cookieJar: cookieJar,
          ),
        ],
      ),
      contextProvider: contextProvider,
      cookieJar: cookieJar,
      onSolved: () {
        ref.invalidate(bypassDdosHeadersProvider);
        ref.invalidate(cachedBypassDdosHeadersProvider);
      },
    );
  },
);

final bypassDdosHeadersProvider =
    FutureProvider.family<Map<String, String>, String>((ref, url) async {
      final cookieJar = ref.watch(cookieJarProvider);

      final cookies = await (await cookieJar()).loadForRequest(Uri.parse(url));

      if (cookies.isEmpty) return const {};

      final cookieString = cookies
          .map((c) => '${c.name}=${c.value}')
          .join('; ');

      final webviewController = WebViewController();
      final userAgent = await webviewController.getUserAgent();

      return {
        if (cookieString.isNotEmpty) 'cookie': cookieString,
        if (userAgent != null && userAgent.isNotEmpty) 'user-agent': userAgent,
      };
    });

final cachedBypassDdosHeadersProvider =
    Provider.family<Map<String, String>, String>((ref, url) {
      final headers = ref.watch(bypassDdosHeadersProvider(url));

      return headers.maybeWhen(
        data: (value) => value,
        orElse: () => const {},
      );
    });
