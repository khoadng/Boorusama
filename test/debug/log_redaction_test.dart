import 'dart:io';
import 'dart:typed_data';

import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/http/client/src/interceptors/dio_logger_interceptor.dart';
import 'package:boorusama/foundation/filesystem.dart';
import 'package:boorusama/foundation/loggers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('URL redaction removes fragments without adding a trailing marker', () {
    for (final url in [
      'https://example.com/posts',
      'https://example.com/posts#',
      'https://example.com/posts#SECRET',
    ]) {
      expect(redactLogUri(Uri.parse(url)), 'https://example.com/posts');
      expect(redactLogMessage('GET $url'), 'GET https://example.com/posts');
    }
    final redacted = redactLogUri(
      Uri.parse('https://example.com/posts?key=SECRET#FRAGMENT'),
    );
    expect(Uri.parse(redacted).hasFragment, isFalse);
    expect(Uri.parse(redacted).queryParameters['key'], '[REDACTED]');
    expect(redactLogUri(Uri.parse(redacted)), redacted);
  });

  test('default storage redacts encoded URLs, headers and nested fields', () {
    final logger = AppLogger();
    logger.info(
      'Network',
      'https://user:USER_SECRET@example.com/posts?api%5Fkey=URL_SECRET&api_key=SECOND_SECRET#FRAGMENT_SECRET\n'
          'Authorization: Bearer HEADER_SECRET\n'
          'Cookie: session=COOKIE_SECRET\n'
          '{"nested":{"password":"BODY_SECRET","refresh_token":"TOKEN_SECRET"}}',
    );
    final output = logger.dump();
    expect(output, isNot(contains('_SECRET')));
    expect(output, contains('example.com/posts'));
    expect(logger.logs.single.sensitiveMessage, isNull);
  });

  test(
    'opt-in applies only to new entries and disabling discards raw details',
    () {
      final logger = AppLogger();
      logger.info('Network', 'safe', sensitiveMessage: 'OLD_SECRET');
      logger.applyCaptureOptions(
        const LogCaptureOptions(includeSensitiveDetails: true),
      );
      expect(logger.dump(), isNot(contains('OLD_SECRET')));
      logger.info('Network', 'safe', sensitiveMessage: 'NEW_SECRET');
      expect(logger.dump(), contains('NEW_SECRET'));
      expect(logger.dump(), contains('SENSITIVE DETAILS INCLUDED'));
      logger.applyCaptureOptions(LogCaptureOptions.defaults);
      expect(logger.dump(), isNot(contains('SECRET')));
      logger.applyCaptureOptions(
        const LogCaptureOptions(includeSensitiveDetails: true),
      );
      expect(logger.dump(), isNot(contains('SECRET')));
      expect(AppLogger().includeSensitiveDetails, isFalse);
    },
  );

  test('fanout never gives raw details to a destination while disabled', () {
    final destination = _RecordingLogger();
    final store = AppLogger(output: MultiChannelLogger(loggers: [destination]));
    final logger = store;
    logger.info(
      'Network',
      'api_key=KEY_SECRET',
      sensitiveMessage: 'RAW_SECRET',
    );
    expect(destination.messages.single, isNot(contains('SECRET')));
    store.applyCaptureOptions(
      const LogCaptureOptions(includeSensitiveDetails: true),
    );
    logger.info('Network', 'safe', sensitiveMessage: 'RAW_SECRET');
    expect(destination.messages.last, 'RAW_SECRET');
    store.applyCaptureOptions(LogCaptureOptions.defaults);
    logger.info('Network', 'api_key=KEY_SECRET');
    expect(destination.messages.last, isNot(contains('SECRET')));
    expect(store.dump(), isNot(contains('SECRET')));
  });

  test(
    'real interceptor excludes arbitrary error bodies until opt-in',
    () async {
      final store = AppLogger();
      final dio = Dio()..httpClientAdapter = _RejectingAdapter();
      addTearDown(dio.close);
      dio.interceptors.add(LoggingInterceptor(logger: store));
      Future<void> record() => expectLater(
        dio.get<Object>('https://example.com/api?api_key=KEY_SECRET'),
        throwsA(isA<DioException>()),
      );
      await record();
      expect(store.dump(), isNot(contains('SECRET')));
      expect(store.dump(), contains('403'));
      store.applyCaptureOptions(
        const LogCaptureOptions(includeSensitiveDetails: true),
      );
      await record();
      expect(store.dump(), contains('BODY_SECRET'));
      store.applyCaptureOptions(LogCaptureOptions.defaults);
      expect(store.dump(), isNot(contains('SECRET')));
    },
  );

  test(
    'file export and clipboard formatter use the same safe snapshot',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'booru-log-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = AppLogger()
        ..applyCaptureOptions(
          const LogCaptureOptions(includeSensitiveDetails: true),
        );
      store.info('Network', 'safe', sensitiveMessage: 'RAW_SECRET');
      final sensitiveFile = await writeDebugLogsToFilePath(
        const IoFileSystem(),
        directory.path,
        store.logs,
      );
      expect(await File(sensitiveFile).readAsString(), store.dump());
      expect(store.dump(), contains('SENSITIVE DETAILS INCLUDED'));
      store.applyCaptureOptions(LogCaptureOptions.defaults);
      final safeFile = await writeDebugLogsToFilePath(
        const IoFileSystem(),
        directory.path,
        store.logs,
      );
      expect(await File(safeFile).readAsString(), store.dump());
      expect(store.dump(), isNot(contains('RAW_SECRET')));
    },
  );
}

class _RecordingLogger implements Logger {
  final messages = <String>[];
  @override
  String getDebugName() => 'recording destination';
  @override
  void info(String serviceName, String message, {String? sensitiveMessage}) {
    messages.add(sensitiveMessage ?? message);
  }

  @override
  void debug(String serviceName, String message, {String? sensitiveMessage}) =>
      throw UnimplementedError();
  @override
  void error(String serviceName, String message, {String? sensitiveMessage}) =>
      throw UnimplementedError();
  @override
  void warn(String serviceName, String message, {String? sensitiveMessage}) =>
      throw UnimplementedError();
  @override
  void verbose(
    String serviceName,
    String message, {
    String? sensitiveMessage,
  }) => throw UnimplementedError();
}

class _RejectingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString('<html>unlabelled BODY_SECRET</html>', 403);

  @override
  void close({bool force = false}) {}
}
