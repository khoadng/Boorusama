// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'protection_overlay.dart';

abstract class ProtectionSolver {
  /// The type of protection this solver handles
  String get protectionType;

  /// Whether this solver is currently busy solving a challenge
  bool get isSolving;

  /// Solves the protection challenge and returns when done
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  });

  /// Cancels an ongoing solving process if possible
  Future<void> cancel();
}

typedef ContextProvider = BuildContext? Function();

class RawSolver implements ProtectionSolver {
  RawSolver({
    required this.protectionType,
    required this.protectionTitle,
    required this.autoCookieValidator,
    required this.contextProvider,
    required this.cookieJar,
  });

  @override
  final String protectionType;
  final String protectionTitle;
  final bool Function(Cookie) autoCookieValidator;
  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  final _cookieManager = WebviewCookieManager();
  var _solving = false;

  @override
  bool get isSolving => _solving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) async {
    if (_solving) return false;
    _solving = true;

    final controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.loadRequest(uri);
    if (userAgent != null) await controller.setUserAgent(userAgent);

    final completer = Completer<bool>();
    final context = contextProvider();

    if (context == null) {
      _solving = false;
      completer.complete(false);
      return completer.future;
    }

    if (!context.mounted) {
      _solving = false;
      completer.complete(false);
      return completer.future;
    }

    final navigator = Navigator.of(context);

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        routeSettings: const RouteSettings(name: 'challenge_solver'),
        builder: (dialogContext) {
          final dialogNavigator = Navigator.of(dialogContext);

          return Dialog.fullscreen(
            child: ProtectionOverlay(
              url: uri.toString(),
              controller: controller,
              onCancel: () => dialogNavigator.pop(false),
              onSolved: () async {
                final cookies = await _cookieManager.getCookies(uri.toString());
                if (cookies.isNotEmpty) {
                  await (await cookieJar()).saveFromResponse(uri, cookies);
                  dialogNavigator.pop(true);
                }
              },
            ),
          );
        },
      );

      _monitorCookies(uri, await cookieJar(), completer, (success) {
        if (navigator.canPop()) navigator.pop();
        if (!completer.isCompleted) completer.complete(success);
      });

      completer.complete(result ?? false);
    } catch (e) {
      completer.complete(false);
    } finally {
      _solving = false;
      // Force completer to resolve if somehow still pending
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    return completer.future.whenComplete(() {
      _solving = false;
    });
  }

  void _monitorCookies(
    Uri uri,
    CookieJar cookieJar,
    Completer<bool> completer,
    Function(bool) onSuccess,
  ) {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_solving) {
        timer.cancel();
        return;
      }

      try {
        final cookies = await _cookieManager.getCookies(uri.toString());
        final hasClearance = cookies.any(autoCookieValidator);

        if (hasClearance) {
          await cookieJar.saveFromResponse(uri, cookies);
          timer.cancel();
          onSuccess(true);
        }
      } catch (e) {
        debugPrint('Error checking cookies: $e');
      }
    });
  }

  @override
  Future<void> cancel() async => _solving = false;
}

class CloudflareSolver implements ProtectionSolver {
  CloudflareSolver({
    required this.contextProvider,
    required this.cookieJar,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  late final _solver = RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    protectionType: 'cloudflare',
    protectionTitle: 'Solving Cloudflare Challenge',
    autoCookieValidator: (cookie) =>
        cookie.name == 'cf_clearance' ||
        cookie.name.contains('cf_') ||
        cookie.name.contains('__cf'),
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}

class McChallengeSolver implements ProtectionSolver {
  McChallengeSolver({
    required this.contextProvider,
    required this.cookieJar,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  late final _solver = RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    protectionType: 'mcchallenge',
    protectionTitle: 'Solving McChallenge Countdown',
    autoCookieValidator: (cookie) => cookie.name.contains('mcchallenge'),
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}

class AftV2Solver implements ProtectionSolver {
  AftV2Solver({
    required this.contextProvider,
    required this.cookieJar,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  late final _solver = RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    protectionType: 'aft_v2',
    protectionTitle: 'Solving verification challenge',
    autoCookieValidator: (cookie) =>
        cookie.name.contains('challenge') ||
        cookie.name.contains('verification') ||
        cookie.name.contains('aft'),
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}

class AftSolver implements ProtectionSolver {
  AftSolver({
    required this.contextProvider,
    required this.cookieJar,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  late final _solver = RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    protectionType: 'aft',
    protectionTitle: 'Solving Anti-DDoS Flood Protection',
    autoCookieValidator: (cookie) {
      // User needs to wait for the challenge to be solved
      return false;
    },
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) async {
    // Before solving, clean up expired timestamp cookies
    try {
      final existingCookies = await (await cookieJar()).loadForRequest(uri);
      if (existingCookies.isNotEmpty) {
        final validCookies = existingCookies.where((cookie) {
          // Keep non-timestamp cookies
          if (!_maybeATimestamp(cookie.value)) {
            return true;
          }

          // For timestamp cookies, only keep valid ones
          final timestamp = int.tryParse(cookie.value);

          // Check if the cookie is a valid timestamp
          if (timestamp != null && _isValidTimestamp(timestamp)) {
            return true;
          }

          // Otherwise, it's an expired timestamp cookie
          return false;
        }).toList();

        // If we had to remove some cookies, update the jar
        if (validCookies.length < existingCookies.length) {
          await (await cookieJar()).saveFromResponse(uri, validCookies);
        }
      }
    } catch (e) {
      debugPrint('Cookie cleanup failed: $e');
    }

    return _solver.solve(
      uri: uri,
      userAgent: userAgent,
    );
  }

  @override
  Future<void> cancel() => _solver.cancel();

  /// Checks if a value is likely to be a Unix timestamp
  bool _maybeATimestamp(String value) {
    // Unix timestamps are typically 9-10 digits
    if (value.length < 9 || value.length > 10) {
      return false;
    }

    return true;
  }

  /// Checks if a timestamp is still valid (not expired)
  bool _isValidTimestamp(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return timestamp > now;
  }
}
