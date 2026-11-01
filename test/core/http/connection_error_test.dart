// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/errors/types.dart';
import 'package:boorusama/core/http/client/src/types/http_utils.dart';

void main() {
  final cases = [
    (
      error: 'HandshakeException: Handshake error in client (OS Error: CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate)',
      expected: AppErrorType.certificateError,
    ),
    (
      error: 'net::ERR_CERT_AUTHORITY_INVALID',
      expected: AppErrorType.certificateError,
    ),
    (
      error: 'HandshakeException: Connection terminated during handshake',
      expected: AppErrorType.handshakeFailed,
    ),
    (
      error: 'net::ERR_SSL_PROTOCOL_ERROR',
      expected: AppErrorType.handshakeFailed,
    ),
    (
      error: 'SSL_ERROR_SYSCALL',
      expected: AppErrorType.handshakeFailed,
    ),
    (
      error: 'HandshakeException: Handshake error in client (OS Error: TLSV1_ALERT_NO_APPLICATION_PROTOCOL)',
      expected: AppErrorType.handshakeFailed,
    ),
    (
      error: 'SocketException: Connection refused',
      expected: AppErrorType.cannotReachServer,
    ),
  ];

  for (final c in cases) {
    test('reports ${c.error} as ${c.expected.name}', () async {
      final result = await tryFetchRemoteData<void>(
        fetcher: () => throw DioException(
          requestOptions: RequestOptions(path: 'https://example.com'),
          error: c.error,
        ),
      ).run();

      expect(
        result.fold((error) => (error as AppError).type, (_) => null),
        c.expected,
      );
    });
  }
}
