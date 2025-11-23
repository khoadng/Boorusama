// Dart imports:
import 'dart:async';
import 'dart:math' as math;

import 'utils.dart';

bool _defaultTransientHttpStatusCodePredicate(int statusCode) {
  return defaultTransientHttpStatusCodes.contains(statusCode);
}

const defaultTransientHttpStatusCodes = <int>[
  0,
  408,
  500,
  502,
  503,
  504,
];

class FetchStrategyBuilder {
  const FetchStrategyBuilder({
    this.timeout = const Duration(seconds: 30),
    this.totalFetchTimeout = const Duration(minutes: 1),
    this.maxAttempts = 5,
    this.initialPauseBetweenRetries = const Duration(seconds: 1),
    this.exponentialBackoffMultiplier = 2,
    this.transientHttpStatusCodePredicate =
        _defaultTransientHttpStatusCodePredicate,
    this.silent,
  });

  final Duration timeout;
  final Duration totalFetchTimeout;
  final int maxAttempts;
  final Duration initialPauseBetweenRetries;
  final num exponentialBackoffMultiplier;
  final bool Function(int statusCode) transientHttpStatusCodePredicate;
  final bool? silent;

  FetchStrategy build() => (uri, failure) async {
    if (failure == null) {
      return FetchInstructions.attempt(uri: uri, timeout: timeout);
    }

    if (!failure.isRetriableFailure ||
        failure.totalDuration > totalFetchTimeout ||
        failure.attemptCount >= maxAttempts) {
      return FetchInstructions.giveUp(uri: uri, silent: silent);
    }

    final pauseBetweenRetries =
        initialPauseBetweenRetries *
        math.pow(exponentialBackoffMultiplier, failure.attemptCount - 1);

    await Future.delayed(pauseBetweenRetries);

    return FetchInstructions.attempt(uri: uri, timeout: timeout);
  };
}

typedef FetchStrategy =
    Future<FetchInstructions> Function(
      Uri uri,
      FetchFailure? failure,
    );

class FetchInstructions<T> {
  const FetchInstructions.giveUp({
    required this.uri,
    this.silent,
  }) : shouldGiveUp = true,
       timeout = Duration.zero;

  const FetchInstructions.attempt({
    required this.uri,
    required this.timeout,
  }) : shouldGiveUp = false,
       silent = null;

  final bool shouldGiveUp;
  final Duration timeout;
  final Uri uri;
  final bool? silent;

  @override
  String toString() {
    return 'FetchInstructions(shouldGiveUp: $shouldGiveUp, timeout: $timeout, uri: $uri, silent: $silent)';
  }
}

class FetchFailure implements Exception {
  const FetchFailure({
    required this.totalDuration,
    required this.attemptCount,
    this.httpStatusCode,
    this.uri,
    this.originalException,
  }) : assert(attemptCount > 0, 'attemptCount must be greater than 0');

  final Duration totalDuration;
  final int attemptCount;
  final int? httpStatusCode;
  final Uri? uri;
  final dynamic originalException;

  bool get isRetriableFailure =>
      (httpStatusCode != null &&
          _defaultTransientHttpStatusCodePredicate(httpStatusCode!)) ||
      isSocketException(originalException);

  @override
  String toString() {
    return 'FetchFailure: attemptCount: $attemptCount, httpStatusCode: $httpStatusCode, uri: $uri, totalDuration: $totalDuration, originalException: $originalException';
  }
}
