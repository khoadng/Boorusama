import 'dart:io';

import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/flow/retry.dart';
import 'package:test/test.dart';

void main() {
  group('ReleaseFlowRetryPolicy', () {
    test('retries transient network exceptions', () {
      const policy = ReleaseFlowRetryPolicy();

      expect(
        policy.isRetryable(const SocketException('connection reset')),
        true,
      );
    });

    test('retries transient process failures from command output', () {
      const policy = ReleaseFlowRetryPolicy();

      expect(
        policy.isRetryable(
          const ProcessFailure(
            'Command failed with exit code 1: gh workflow run',
            output: 'HTTP 503: service unavailable',
          ),
        ),
        true,
      );
    });

    test('retries Google API status-shaped errors', () {
      const policy = ReleaseFlowRetryPolicy();

      expect(
        policy.isRetryable(
          const _StringException(
            'DetailedApiRequestError(status: 503, message: Backend Error)',
          ),
        ),
        true,
      );
    });

    test('does not retry business failures', () {
      const policy = ReleaseFlowRetryPolicy();

      expect(
        policy.isRetryable(
          const ProcessFailure('Current versionCode is not newer.'),
        ),
        false,
      );
    });
  });
}

final class _StringException implements Exception {
  const _StringException(this.message);

  final String message;

  @override
  String toString() => message;
}
