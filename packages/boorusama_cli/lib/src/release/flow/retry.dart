import 'dart:async';
import 'dart:io';

import '../../io/process_runner.dart';

final class ReleaseFlowRetryPolicy {
  const ReleaseFlowRetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(seconds: 2),
    this.isRetryable = defaultIsRetryable,
  });

  final int maxAttempts;
  final Duration baseDelay;
  final bool Function(Object error) isRetryable;

  Duration delayForRetry(int retryNumber) {
    if (baseDelay == Duration.zero) return Duration.zero;
    return baseDelay * retryNumber;
  }

  static bool defaultIsRetryable(Object error) {
    if (error is TimeoutException ||
        error is SocketException ||
        error is HandshakeException ||
        error is HttpException) {
      return true;
    }

    if (error is ProcessFailure) {
      return _looksTransient('${error.message}\n${error.output}');
    }

    return _looksTransient(error.toString());
  }

  static bool _looksTransient(String text) {
    final value = text.toLowerCase();
    return value.contains('http 429') ||
        value.contains('status code 429') ||
        value.contains('too many requests') ||
        value.contains('rate limit') ||
        value.contains('http 500') ||
        value.contains('status: 500') ||
        value.contains('status 500') ||
        value.contains('code: 500') ||
        value.contains('status code 500') ||
        value.contains('internal server error') ||
        value.contains('http 502') ||
        value.contains('status: 502') ||
        value.contains('status 502') ||
        value.contains('code: 502') ||
        value.contains('status code 502') ||
        value.contains('bad gateway') ||
        value.contains('http 503') ||
        value.contains('status: 503') ||
        value.contains('status 503') ||
        value.contains('code: 503') ||
        value.contains('status code 503') ||
        value.contains('service unavailable') ||
        value.contains('http 504') ||
        value.contains('status: 504') ||
        value.contains('status 504') ||
        value.contains('code: 504') ||
        value.contains('status code 504') ||
        value.contains('gateway timeout') ||
        value.contains('timeout') ||
        value.contains('temporar') ||
        value.contains('connection reset') ||
        value.contains('connection refused') ||
        value.contains('network is unreachable');
  }
}
