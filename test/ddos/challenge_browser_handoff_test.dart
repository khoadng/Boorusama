// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:boorusama/core/ddos/handler/types.dart';
import 'package:boorusama/core/ddos/solver/src/protection_overlay.dart';
import 'package:boorusama/core/ddos/solver/types.dart';
import 'package:boorusama/core/http/client/src/interceptors/dio_protection_interceptor.dart';
import 'package:boorusama/foundation/browser/types.dart';

import 'protection_solver_test.dart' show FakeUserAgentProvider;

// A captcha page branded with the site's name instead of a bare "CAPTCHA".
const _brandedCaptchaPage = '''
<html>
<head>
<title>Example CAPTCHA</title>
<meta http-equiv="refresh" content="360">
</head>
<body>
</body>
</html>''';

// A branded captcha page embedding a Turnstile widget routes to the Cloudflare
// solver.
final _turnstileCaptchaPage = _brandedCaptchaPage.replaceFirst(
  '<body>',
  '<body><script src="https://challenges.cloudflare.com/turnstile/v0/api.js"></script> '
      '<div class="cf-turnstile"></div>',
);

const _actionPath = '/action';
const _openPath = '/open';

void main() {
  group('challenge page for a request', () {
    final cases = [
      (
        description: 'a plain GET opens the request itself',
        method: 'GET',
        stateChanging: false,
        baseUrl: 'https://example.com/booru/',
        expected: 'https://example.com/posts?page=2',
      ),
      (
        description: 'a state-changing GET opens the base page',
        method: 'GET',
        stateChanging: true,
        baseUrl: 'https://example.com/booru/',
        expected: 'https://example.com/booru/',
      ),
      (
        description: 'a POST opens the base page',
        method: 'POST',
        stateChanging: false,
        baseUrl: 'https://example.com/booru/',
        expected: 'https://example.com/booru/',
      ),
      (
        description:
            'a state-changing request on another origin opens that origin root',
        method: 'POST',
        stateChanging: false,
        baseUrl: 'https://other.example.com',
        expected: 'https://example.com/',
      ),
    ];
    for (final c in cases) {
      test(c.description, () {
        final options = RequestOptions(
          method: c.method,
          baseUrl: c.baseUrl,
          path: 'https://example.com/posts?page=2',
          extra: c.stateChanging ? stateChangingRequestExtra : null,
        );

        expect(challengeUriFor(options).toString(), c.expected);
      });
    }
  });

  testWidgets(
    'browser that already holds a clearance cookie hands it to the app and the retry succeeds',
    (tester) async {
      final site = _Site(
        blockedBody: _turnstileCaptchaPage,
        unblockedBy: 'cf_clearance=valid',
      );
      final harness = await _Harness.pump(
        tester,
        site: site,
        browserCookies: const [
          BrowserCookie(
            name: 'cf_clearance',
            value: 'valid',
            domain: 'example.com',
            path: '/',
          ),
        ],
      );

      final sent = await harness.sendAction(tester);

      expect(sent.result, 'HTTP 200 "done"');
      expect(find.byType(ProtectionOverlay), findsNothing);
    },
  );

  testWidgets(
    'solving a captcha for a state-changing request does not replay that request in the challenge browser',
    (tester) async {
      final site = _Site(blockedBody: _turnstileCaptchaPage);
      final harness = await _Harness.pump(tester, site: site);

      await harness.sendAction(tester);
      await harness.cancelChallenge(tester);

      expect(site.browserPaths, isNotEmpty);
      expect(site.actionsPerformedByBrowser, 0);
    },
  );

  testWidgets(
    'after a solve that leaves the app blocked, later requests fail without reopening the challenge',
    (tester) async {
      final site = _Site(blockedBody: _turnstileCaptchaPage);
      final harness = await _Harness.pump(tester, site: site);

      final first = await harness.sendAction(tester);
      final second = await harness.sendAction(tester);

      expect(first.result, 'HTTP 403');
      expect(first.challengeShown, isTrue);
      expect(second.result, 'HTTP 403');
      expect(second.challengeShown, isFalse);
      expect(site.browserPaths, hasLength(1));
    },
  );

  testWidgets(
    'a successful request to the site lets the challenge open again',
    (tester) async {
      final site = _Site(blockedBody: _turnstileCaptchaPage);
      final harness = await _Harness.pump(tester, site: site);

      await harness.sendAction(tester);
      final open = await harness.send(tester, _openPath);
      final retried = await harness.sendAction(tester);

      expect(open.result, 'HTTP 200 "done"');
      expect(retried.challengeShown, isTrue);
      expect(site.browserPaths, hasLength(2));
    },
  );
}

List<ProtectionDetector> _detectors() => [
  CloudflareDetector(),
  AftDetector(),
  CaptchaAccessDeniedDetector(),
];

typedef _Sent = ({String? result, bool challengeShown});

class _Harness {
  _Harness._(this.dio);

  static Future<_Harness> pump(
    WidgetTester tester, {
    required _Site site,
    List<BrowserCookie> browserCookies = const [],
  }) async {
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

    final jar = CookieJar();
    final cookieJar = LazyAsync<CookieJar>(() async => jar);
    final browsers = _BrowserFactory(site, browserCookies);
    BuildContext? contextProvider() => pageContext;
    final handler = HttpProtectionHandler(
      orchestrator: ProtectionOrchestrator(
        detectors: _detectors(),
        solvers: [
          CloudflareSolver(
            contextProvider: contextProvider,
            cookieJar: cookieJar,
            browserFactory: browsers,
          ),
          AftSolver(
            contextProvider: contextProvider,
            cookieJar: cookieJar,
            browserFactory: browsers,
          ),
          CaptchaAccessDeniedSolver(
            contextProvider: contextProvider,
            cookieJar: cookieJar,
            browserFactory: browsers,
          ),
        ],
        userAgentProvider: FakeUserAgentProvider(),
      ),
      contextProvider: contextProvider,
      cookieJar: cookieJar,
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
      ..httpClientAdapter = site;
    dio.interceptors.add(
      DioProtectionInterceptor(protectionHandler: handler, dio: dio),
    );
    return _Harness._(dio);
  }

  final Dio dio;

  Future<_Sent> sendAction(WidgetTester tester) =>
      send(tester, _actionPath, stateChanging: true);

  /// Sends a request and pumps frames until it settles or a challenge has been
  /// left open for a few seconds.
  Future<_Sent> send(
    WidgetTester tester,
    String path, {
    bool stateChanging = false,
  }) async {
    String? result;
    var challengeShown = false;
    unawaited(
      dio
          .get<String>(
            path,
            options: Options(
              extra: stateChanging ? stateChangingRequestExtra : null,
            ),
          )
          .then(
            (r) => result = 'HTTP ${r.statusCode} "${r.data}"',
            onError: (Object e) => result = switch (e) {
              DioException(:final response?) => 'HTTP ${response.statusCode}',
              _ => e.toString(),
            },
          ),
    );
    for (var frame = 0; frame < 200 && result == null; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (find.byType(ProtectionOverlay).evaluate().isNotEmpty) {
        challengeShown = true;
      }
    }
    await tester.pump(const Duration(seconds: 2));
    return (result: result, challengeShown: challengeShown);
  }

  Future<void> cancelChallenge(WidgetTester tester) async {
    final overlay = find.byType(ProtectionOverlay);
    if (overlay.evaluate().isNotEmpty) {
      tester.widget<ProtectionOverlay>(overlay).onCancel();
    }
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  }
}

/// The app's HTTP client is blocked on [_actionPath] unless its cookie header
/// carries [unblockedBy]. A real browser, already logged in, is never
/// challenged.
class _Site implements HttpClientAdapter {
  _Site({required this.blockedBody, this.unblockedBy});

  final String blockedBody;
  final String? unblockedBy;
  var appRequests = 0;
  var actionsPerformedByBrowser = 0;
  final browserPaths = <String>[];

  String browserPage(Uri uri) => switch ((browserPaths..add(uri.path)).last) {
    _actionPath => () {
      actionsPerformedByBrowser++;
      return '<html><head></head><body>done</body></html>';
    }(),
    _ => '<html><head><title>Example</title></head><body>home</body></html>',
  };

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    appRequests++;
    final cookie = options.headers.entries
        .where((e) => e.key.toLowerCase() == 'cookie')
        .map((e) => '${e.value}')
        .firstOrNull;
    final unblocked =
        options.uri.path == _openPath ||
        switch ((unblockedBy, cookie)) {
          (final key?, final cookie?) => cookie.contains(key),
          _ => false,
        };
    return switch (unblocked) {
      true => ResponseBody.fromString('done', 200),
      false => ResponseBody.fromString(
        blockedBody,
        403,
        headers: {
          Headers.contentTypeHeader: ['text/html'],
        },
      ),
    };
  }

  @override
  void close({bool force = false}) {}
}

class _BrowserFactory implements EmbeddedBrowserFactory {
  _BrowserFactory(this.site, this.cookies);

  final _Site site;
  final List<BrowserCookie> cookies;

  @override
  Future<BrowserAvailability> checkAvailability({
    bool forceRefresh = false,
  }) async => const BrowserAvailability(
    kind: BrowserAvailabilityKind.available,
    backend: BrowserBackend.flutterWebView,
  );

  @override
  Future<EmbeddedBrowserSession> createSession() async =>
      _Browser(site, cookies);

  @override
  Future<String?> getDefaultUserAgent() async => 'FakeBrowser/1.0';
}

class _Browser implements EmbeddedBrowserSession {
  _Browser(this.site, this.cookies);

  final _Site site;
  final List<BrowserCookie> cookies;
  final _events = StreamController<BrowserEvent>.broadcast();
  Uri? _current;
  var _page = '';

  @override
  BrowserBackend get backend => BrowserBackend.flutterWebView;

  @override
  Stream<BrowserEvent> get events => _events.stream;

  @override
  Future<void> load(Uri uri) async {
    _current = uri;
    _events.add(
      BrowserEvent(kind: BrowserEventKind.navigationStarted, uri: uri),
    );
    _page = site.browserPage(uri);
    scheduleMicrotask(
      () => _events.add(
        BrowserEvent(kind: BrowserEventKind.navigationCompleted, uri: uri),
      ),
    );
  }

  @override
  Future<void> setUserAgent(String userAgent) async {}

  @override
  Future<String?> getUserAgent() async => 'FakeBrowser/1.0';

  @override
  Future<Uri?> currentUri() async => _current;

  @override
  Future<Object?> evaluateJavaScript(String source) async => jsonEncode(_page);

  @override
  Future<List<BrowserCookie>> getCookies(Uri uri) async => cookies;

  @override
  Widget buildView({Key? key}) => SizedBox(key: key);

  @override
  Future<void> dispose() => _events.close();
}
