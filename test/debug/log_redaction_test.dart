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

  test('redaction preserves diagnostic parameters and repeated values', () {
    final uri = Uri.parse(
      'https://example.com/posts?limit=100&page=2&tags=cat%20dog'
      '&tags=rating%3Asafe&rating_service_key=service&token_count=7'
      '&api%5Fkey=FIRST_SECRET&api_key=SECOND_SECRET&key=THIRD_SECRET',
    );
    for (final output in [
      redactLogUri(uri),
      redactLogMessage('GET $uri').substring(4),
    ]) {
      final params = Uri.parse(output).queryParametersAll;
      expect(params['limit'], ['100']);
      expect(params['page'], ['2']);
      expect(params['tags'], ['cat dog', 'rating:safe']);
      expect(params['rating_service_key'], ['service']);
      expect(params['token_count'], ['7']);
      expect(params['api_key'], ['[REDACTED]', '[REDACTED]']);
      expect(params['key'], ['[REDACTED]']);
      expect(output, isNot(contains('SECRET')));
    }
    expect(
      redactLogMessage('limit=100 rating_service_key=service token_count=7'),
      'limit=100 rating_service_key=service token_count=7',
    );
  });

  test('redaction hides encoded URLs, headers and nested fields', () {
    final logger = AppLogger()
      ..applyOptions(const LogOptions(redactSensitiveDetails: true));
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

  test('redaction is reversible for existing and newly captured details', () {
    final logger = AppLogger();
    logger.info('Network', 'safe', sensitiveMessage: 'STARTUP_SECRET');
    expect(logger.dump(), contains('STARTUP_SECRET'));
    logger.applyOptions(const LogOptions(redactSensitiveDetails: true));
    logger.info('Network', 'safe', sensitiveMessage: 'LATER_SECRET');
    expect(logger.dump(), isNot(contains('SECRET')));
    expect(logger.logs.every((log) => log.sensitiveMessage == null), isTrue);
    logger.applyOptions(LogOptions.defaults);
    expect(logger.dump(), contains('STARTUP_SECRET'));
    expect(logger.dump(), contains('LATER_SECRET'));
    expect(logger.dump(), contains('SENSITIVE DETAILS INCLUDED'));
    logger.clearLogsAtOrBelow(LogLevel.error);
    logger.applyOptions(const LogOptions(redactSensitiveDetails: true));
    logger.applyOptions(LogOptions.defaults);
    expect(logger.logs, isEmpty);
  });

  test('fanout never gives raw details to a destination while disabled', () {
    final destination = _RecordingLogger();
    final store = AppLogger(output: MultiChannelLogger(loggers: [destination]))
      ..applyOptions(const LogOptions(redactSensitiveDetails: true));
    final logger = store;
    logger.info(
      'Network',
      'api_key=KEY_SECRET',
      sensitiveMessage: 'RAW_SECRET',
    );
    expect(destination.messages.single, isNot(contains('SECRET')));
    store.applyOptions(
      LogOptions.defaults,
    );
    logger.info('Network', 'safe', sensitiveMessage: 'RAW_SECRET');
    expect(destination.messages.last, 'RAW_SECRET');
    store.applyOptions(const LogOptions(redactSensitiveDetails: true));
    logger.info('Network', 'api_key=KEY_SECRET');
    expect(destination.messages.last, isNot(contains('SECRET')));
    expect(store.dump(), isNot(contains('SECRET')));
  });

  test(
    'redaction can reveal an already captured HTTP failure without retrying',
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
      expect(store.dump(), contains('BODY_SECRET'));
      store.applyOptions(const LogOptions(redactSensitiveDetails: true));
      expect(store.dump(), isNot(contains('SECRET')));
      expect(store.dump(), contains('403'));
      store.applyOptions(
        LogOptions.defaults,
      );
      expect(store.dump(), contains('BODY_SECRET'));
      store.applyOptions(const LogOptions(redactSensitiveDetails: true));
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
        ..applyOptions(
          LogOptions.defaults,
        );
      store.updateReportContext({
        'app': '1.2.3+45',
        'networkTransports': 'wifi',
      });
      store.info('Network', 'safe', sensitiveMessage: 'RAW_SECRET');
      final sensitiveFile = await writeDebugLogsToFilePath(
        const IoFileSystem(),
        directory.path,
        store.logs,
        context: store.reportContext,
      );
      expect(await File(sensitiveFile).readAsString(), store.dump());
      expect(store.dump(), contains('SENSITIVE DETAILS INCLUDED'));
      store.applyOptions(const LogOptions(redactSensitiveDetails: true));
      final safeFile = await writeDebugLogsToFilePath(
        const IoFileSystem(),
        directory.path,
        store.logs,
        context: store.reportContext,
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
