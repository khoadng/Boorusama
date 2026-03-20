// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/ddos/solver/src/protection_detector.dart';
import 'package:boorusama/core/ddos/solver/src/protection_orchestrator.dart';
import 'package:boorusama/core/ddos/solver/src/protection_solver.dart';
import 'package:boorusama/core/ddos/solver/src/types.dart';
import 'package:boorusama/core/ddos/solver/src/user_agent_provider.dart';

class FakeCookieRetriever implements CookieRetriever {
  List<Cookie> Function(String url)? onGetCookies;

  @override
  Future<List<Cookie>> getCookies(String url) async {
    return onGetCookies?.call(url) ?? [];
  }
}

class FakeCookieJar implements CookieJar {
  final saved = <Uri, List<Cookie>>{};

  @override
  final ignoreExpires = false;

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    saved[uri] = cookies;
  }

  @override
  Future<List<Cookie>> loadForRequest(Uri uri) async {
    return saved[uri] ?? [];
  }

  @override
  Future<void> delete(Uri uri, [bool withDomainSharedCookie = false]) async {
    saved.remove(uri);
  }

  @override
  Future<void> deleteAll() async {
    saved.clear();
  }
}

class FakeProtectionSolver implements ProtectionSolver {
  var solveResult = true;
  var solveCallCount = 0;

  @override
  String get protectionType => 'cloudflare';

  @override
  bool get isSolving => false;

  @override
  Future<bool> solve({required Uri uri, String? userAgent}) async {
    solveCallCount++;
    return solveResult;
  }

  @override
  Future<void> cancel() async {}
}

class FakeUserAgentProvider implements UserAgentProvider {
  @override
  Future<String?> getUserAgent() async => 'TestAgent/1.0';
}

class FakeHttpResponse implements HttpResponse {
  FakeHttpResponse({this.statusCode, this.data, Uri? requestUri})
    : requestUri = requestUri ?? Uri.parse('https://example.com');

  @override
  final int? statusCode;
  @override
  final dynamic data;
  @override
  final Uri requestUri;
  @override
  Map<String, dynamic> get headers => {};
}

class FakeHttpError implements HttpError {
  FakeHttpError({this.response, this.message, Uri? requestUri})
    : requestUri = requestUri ?? Uri.parse('https://example.com');

  @override
  final HttpResponse? response;
  @override
  final Uri requestUri;
  @override
  final String? message;
}

void main() {
  group('waitForAutoSolve', () {
    late FakeCookieRetriever cookieRetriever;
    late FakeCookieJar cookieJar;

    setUp(() {
      cookieRetriever = FakeCookieRetriever();
      cookieJar = FakeCookieJar();
    });

    bool cfValidator(Cookie c) => c.name == 'cf_clearance';

    test('returns true when clearance cookie appears', () async {
      var callCount = 0;
      cookieRetriever.onGetCookies = (_) {
        callCount++;
        if (callCount >= 2) return [Cookie('cf_clearance', 'abc123')];
        return [];
      };

      final result = await waitForAutoSolve(
        uri: Uri.parse('https://example.com'),
        jar: cookieJar,
        cookieRetriever: cookieRetriever,
        autoCookieValidator: cfValidator,
        isCancelled: () => false,
        pollInterval: Duration.zero,
      );

      expect(result, true);
      expect(cookieJar.saved.isNotEmpty, true);
    });

    test('saves cookies to jar with correct URI', () async {
      final uri = Uri.parse('https://cdn.donmai.us/original/image.jpg');
      cookieRetriever.onGetCookies = (_) => [
        Cookie('cf_clearance', 'token'),
      ];

      await waitForAutoSolve(
        uri: uri,
        jar: cookieJar,
        cookieRetriever: cookieRetriever,
        autoCookieValidator: cfValidator,
        isCancelled: () => false,
        pollInterval: Duration.zero,
      );

      expect(cookieJar.saved[uri]!.first.value, 'token');
    });

    test('returns false when no matching cookies appear', () async {
      cookieRetriever.onGetCookies = (_) => [
        Cookie('session_id', 'xyz'),
      ];

      final result = await waitForAutoSolve(
        uri: Uri.parse('https://example.com'),
        jar: cookieJar,
        cookieRetriever: cookieRetriever,
        autoCookieValidator: cfValidator,
        isCancelled: () => false,
        maxAttempts: 2,
        pollInterval: Duration.zero,
      );

      expect(result, false);
      expect(cookieJar.saved.isEmpty, true);
    });

    test('returns false when cancelled', () async {
      var callCount = 0;
      var cancelled = false;
      cookieRetriever.onGetCookies = (_) {
        callCount++;
        if (callCount >= 2) cancelled = true;
        return [];
      };

      final result = await waitForAutoSolve(
        uri: Uri.parse('https://example.com'),
        jar: cookieJar,
        cookieRetriever: cookieRetriever,
        autoCookieValidator: cfValidator,
        isCancelled: () => cancelled,
        pollInterval: Duration.zero,
      );

      expect(result, false);
    });

    test('returns false when cookie retriever throws', () async {
      cookieRetriever.onGetCookies = (_) => throw Exception('Network error');

      final result = await waitForAutoSolve(
        uri: Uri.parse('https://example.com'),
        jar: cookieJar,
        cookieRetriever: cookieRetriever,
        autoCookieValidator: cfValidator,
        isCancelled: () => false,
        maxAttempts: 2,
        pollInterval: Duration.zero,
      );

      expect(result, false);
    });

    test('returns false when cookies are empty', () async {
      cookieRetriever.onGetCookies = (_) => [];

      final result = await waitForAutoSolve(
        uri: Uri.parse('https://example.com'),
        jar: cookieJar,
        cookieRetriever: cookieRetriever,
        autoCookieValidator: cfValidator,
        isCancelled: () => false,
        maxAttempts: 2,
        pollInterval: Duration.zero,
      );

      expect(result, false);
    });
  });

  group('ProtectionOrchestrator', () {
    late FakeProtectionSolver fakeSolver;
    late FakeUserAgentProvider fakeUaProvider;

    setUp(() {
      fakeSolver = FakeProtectionSolver();
      fakeUaProvider = FakeUserAgentProvider();
    });

    test('returns false when no detector matches', () async {
      final orchestrator = ProtectionOrchestrator(
        detectors: [CloudflareDetector()],
        solvers: [fakeSolver],
        userAgentProvider: fakeUaProvider,
      );

      final error = FakeHttpError(
        response: FakeHttpResponse(statusCode: 200, data: 'OK'),
      );

      final result = await orchestrator.handleError(
        _FakeBuildContext(),
        error,
      );
      expect(result, false);
      expect(fakeSolver.solveCallCount, 0);
    });

    test('returns false when no solver matches detector type', () async {
      final orchestrator = ProtectionOrchestrator(
        detectors: [CloudflareDetector()],
        solvers: [],
        userAgentProvider: fakeUaProvider,
      );

      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 403,
          data: 'cloudflare cf_chl challenge',
        ),
      );

      final result = await orchestrator.handleError(
        _FakeBuildContext(),
        error,
      );
      expect(result, false);
    });

    test('deduplicates concurrent requests for the same URI', () async {
      final solveCompleter = Completer<bool>();
      final slowSolver = _SlowSolver(completer: solveCompleter);

      final orchestrator = ProtectionOrchestrator(
        detectors: [CloudflareDetector()],
        solvers: [slowSolver],
        userAgentProvider: fakeUaProvider,
      );

      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 403,
          data: 'cloudflare cf_chl challenge',
        ),
      );

      final first = orchestrator.handleError(_FakeBuildContext(), error);
      final second = orchestrator.handleError(_FakeBuildContext(), error);

      solveCompleter.complete(true);

      expect(await first, true);
      expect(await second, true);
      expect(slowSolver.solveCallCount, 1);
    });

    test('sets hasSolvedChallenge after successful solve', () async {
      final orchestrator = ProtectionOrchestrator(
        detectors: [CloudflareDetector()],
        solvers: [fakeSolver],
        userAgentProvider: fakeUaProvider,
      );

      expect(orchestrator.hasSolvedChallenge, false);

      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 403,
          data: 'cloudflare cf_chl challenge',
        ),
      );

      await orchestrator.handleError(_FakeBuildContext(), error);
      expect(orchestrator.hasSolvedChallenge, true);
    });

    test('only uses error-phase detectors for handleError', () async {
      final orchestrator = ProtectionOrchestrator(
        detectors: [McChallengeDetector()],
        solvers: [fakeSolver],
        userAgentProvider: fakeUaProvider,
      );

      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 200,
          data:
              'mccaptcha mcchallenge _challenge/mccaptcha _challenge/verify captcha_text',
        ),
      );

      final result = await orchestrator.handleError(
        _FakeBuildContext(),
        error,
      );
      expect(result, false);
      expect(fakeSolver.solveCallCount, 0);
    });

    test('only uses response-phase detectors for handleResponse', () async {
      final orchestrator = ProtectionOrchestrator(
        detectors: [CloudflareDetector()],
        solvers: [fakeSolver],
        userAgentProvider: fakeUaProvider,
      );

      final response = FakeHttpResponse(
        statusCode: 403,
        data: 'cloudflare cf_chl challenge',
      );

      final result = await orchestrator.handleResponse(response);
      expect(result, false);
      expect(fakeSolver.solveCallCount, 0);
    });

    test('handles solver exception gracefully', () async {
      final orchestrator = ProtectionOrchestrator(
        detectors: [CloudflareDetector()],
        solvers: [_ThrowingSolver()],
        userAgentProvider: fakeUaProvider,
      );

      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 403,
          data: 'cloudflare cf_chl challenge',
        ),
      );

      final result = await orchestrator.handleError(
        _FakeBuildContext(),
        error,
      );
      expect(result, false);
    });
  });
}

class _SlowSolver implements ProtectionSolver {
  _SlowSolver({required this.completer});

  final Completer<bool> completer;
  var solveCallCount = 0;

  @override
  String get protectionType => 'cloudflare';
  @override
  bool get isSolving => false;

  @override
  Future<bool> solve({required Uri uri, String? userAgent}) {
    solveCallCount++;
    return completer.future;
  }

  @override
  Future<void> cancel() async {}
}

class _ThrowingSolver implements ProtectionSolver {
  @override
  String get protectionType => 'cloudflare';
  @override
  bool get isSolving => false;

  @override
  Future<bool> solve({required Uri uri, String? userAgent}) {
    throw Exception('Solver crashed');
  }

  @override
  Future<void> cancel() async {}
}

class _FakeBuildContext extends Fake implements BuildContext {}
