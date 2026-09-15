// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

// Project imports:
import 'package:boorusama/core/ddos/solver/src/protection_diagnostics.dart';
import 'package:boorusama/core/ddos/solver/src/protection_overlay.dart';
import 'package:boorusama/core/ddos/solver/src/protection_solver.dart';

import 'protection_solver_test.dart' show FakeCookieJar, FakeCookieRetriever;

void main() {
  for (final trigger in CheckTrigger.values) {
    testWidgets(
      'rejected page stays open, then ${trigger.name} completion records its close',
      (tester) async {
        final platform = _WebViewPlatform();
        WebViewPlatform.instance = platform;
        final records = <ProtectionRecord>[];
        final session = ProtectionSession(
          host: 'example.com',
          type: 'cloudflare',
          onEvent: (record, {sensitive}) => records.add(record),
        );
        late BuildContext pageContext;
        await tester.pumpWidget(
          BooruLocalization(
            child: MaterialApp(
              builder: (context, child) => KurumiTheme(
                data: KurumiThemeData.fromMaterial(Theme.of(context)),
                child: child!,
              ),
              home: Builder(
                builder: (context) {
                  pageContext = context;
                  return const Scaffold(body: Text('Home'));
                },
              ),
            ),
          ),
        );
        final solver = RawSolver(
          protectionType: 'cloudflare',
          protectionTitle: 'Challenge',
          autoCookieValidator: (cookie) => cookie.name == 'cf_clearance',
          contextProvider: () => pageContext,
          cookieJar: LazyAsync(() async => FakeCookieJar()),
          cookieRetriever: FakeCookieRetriever(),
          pageEvaluator: evaluateCloudflarePage,
        );
        final result = solver.solve(
          uri: Uri.parse('https://example.com/image'),
          diagnostics: session,
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProtectionOverlay), findsOneWidget);
        expect(
          platform.controller.loadedUri,
          Uri.parse('https://example.com/image'),
        );
        platform.delegate.finished!('https://example.com/image');
        await tester.pump();
        expect(find.byType(ProtectionOverlay), findsOneWidget);
        final rejected = records
            .map((record) => record.event)
            .whereType<PageEvaluated>()
            .single;
        expect(rejected.evaluation.reason, PageDecisionReason.challengeMarker);
        expect(platform.controller.reads, 1);
        expect(
          records
              .map((record) => record.event)
              .whereType<DialogCloseRequested>(),
          isEmpty,
        );
        platform.controller.source = '<html>normal page</html>';
        switch (trigger) {
          case CheckTrigger.pageFinished:
            platform.delegate.finished!('https://example.com/image');
          case CheckTrigger.manual:
            tester
                .widget<ProtectionOverlay>(find.byType(ProtectionOverlay))
                .onSolved();
          case CheckTrigger.timer:
            await tester.pump(const Duration(seconds: 1));
        }
        await tester.pumpAndSettle();
        expect(await result, isTrue);
        expect(find.byType(ProtectionOverlay), findsNothing);
        expect(find.text('Home'), findsOneWidget);
        final closeRecord = records.singleWhere(
          (record) => record.event is DialogCloseRequested,
        );
        final close = closeRecord.event as DialogCloseRequested;
        expect(close.trigger.name, trigger.name);
        expect(close.routeId, isNotNull);
        expect(close.routeIsCurrent, isTrue);
        expect(close.canPop, isTrue);
        expect(closeRecord.scope.checkId, isNotNull);
        final started = records.singleWhere(
          (record) =>
              record.scope.checkId == closeRecord.scope.checkId &&
              record.event is CompletionCheckStarted,
        );
        expect((started.event as CompletionCheckStarted).trigger, trigger);
        final completed = records.singleWhere(
          (record) =>
              record.scope.checkId == closeRecord.scope.checkId &&
              record.event is CompletionCheckFinished,
        );
        expect(
          (completed.event as CompletionCheckFinished).outcome,
          CheckOutcome.pageAccepted,
        );
        expect(
          records
              .map((record) => record.event)
              .whereType<DialogClosed>()
              .single
              .result,
          isTrue,
        );
        expect(platform.controller.reads, 2);
        // Let the existing polling timer observe completion and cancel itself.
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _WebViewPlatform extends WebViewPlatform {
  late _Controller controller;
  late _Delegate delegate;
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => controller = _Controller(params);
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => delegate = _Delegate(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _WebViewWidget(params);
}

class _Controller extends PlatformWebViewController {
  _Controller(super.params) : super.implementation();
  var source = '<html>cf_chl</html>';
  Uri? loadedUri;
  var reads = 0;
  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}
  @override
  Future<void> setUserAgent(String? userAgent) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    loadedUri = params.uri;
  }

  @override
  Future<String?> currentUrl() async => loadedUri?.toString();
  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    if (!javaScript.contains('document.documentElement')) {
      throw UnsupportedError('Unexpected script');
    }
    reads++;
    return jsonEncode(source);
  }
}

class _Delegate extends PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();
  PageEventCallback? finished;
  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}
  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    finished = onPageFinished;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}
}

class _WebViewWidget extends PlatformWebViewWidget {
  _WebViewWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox();
}
