// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/platform.dart';
import '../../../foundation/webview_user_agent.dart';
import '../../debug/providers.dart';
import '../../http/cookies/providers.dart';
import '../../router.dart';
import '../diagnostics/providers.dart';
import '../solver/providers.dart';
import '../solver/types.dart';
import 'protection_handler.dart';

final httpDdosProtectionBypassProvider = Provider<HttpProtectionHandler>(
  (ref) {
    final cookieJar = ref.watch(cookieJarProvider);
    final recorder = ref.watch(protectionLogRecorderProvider);
    final platform = ref.watch(appPlatformProvider);
    final supportsEmbeddedWebView = platform.supportsEmbeddedWebView;
    BuildContext? contextProvider() {
      final key = ref.read(appNavigationProvider).navigatorKey;
      final context = key.currentContext ?? key.currentState?.context;

      return context;
    }

    return HttpProtectionHandler(
      onEvent: recorder.record,
      orchestrator: ProtectionOrchestrator(
        userAgentProvider: supportsEmbeddedWebView
            ? WebViewUserAgentProvider(
                service: ref.watch(webViewUserAgentServiceProvider),
                onUserAgent: (ua) {
                  final engine =
                      RegExp(
                        '(?:Chrome|AppleWebKit)/[0-9.]+',
                      ).firstMatch(ua ?? '')?.group(0) ??
                      'unknown';
                  ref.read(appLoggerProvider).updateReportContext({
                    'webViewEngineFromUserAgent': engine,
                  });
                },
              )
            : const UnavailableUserAgentProvider(),
        detectors: [
          CloudflareDetector(),
          AftDetector(),
          CaptchaAccessDeniedDetector(),
        ],
        solvers: supportsEmbeddedWebView
            ? [
                CloudflareSolver(
                  contextProvider: contextProvider,
                  cookieJar: cookieJar,
                ),
                AftSolver(
                  contextProvider: contextProvider,
                  cookieJar: cookieJar,
                ),
                CaptchaAccessDeniedSolver(
                  contextProvider: contextProvider,
                  cookieJar: cookieJar,
                ),
              ]
            : const [],
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

      final userAgent = await ref
          .watch(webViewUserAgentServiceProvider)
          .getUserAgent();

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
