import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_client_helper/http_client_helper.dart' hide Response;

import 'fetch_strategy.dart';

Future<Response<T>?> tryGetResponse<T>(
  Uri uri, {
  required Dio dio,
  CancellationToken? cancelToken,
  FetchStrategyBuilder? fetchStrategy,
  void Function(int count, int total)? onReceiveProgress,
  Options? options,
}) async {
  cancelToken?.throwIfCancellationRequested();
  final stopwatch = Stopwatch()..start();
  final builder = fetchStrategy ?? _defaultFetchStrategy;
  final strategy = builder.build();
  var instructions = await strategy(uri, null);
  _debugCheckInstructions(instructions);
  var attemptCount = 0;
  FetchFailure? lastFailure;

  final effectiveOptions = options ?? Options();

  while (!instructions.shouldGiveUp) {
    attemptCount++;
    cancelToken?.throwIfCancellationRequested();
    try {
      final response = await dio.getUri<T>(
        instructions.uri,
        options: effectiveOptions.copyWith(
          receiveTimeout: instructions.timeout,
          validateStatus: (status) => status == HttpStatus.ok,
        ),
        onReceiveProgress: onReceiveProgress,
      );

      if (response.data == null) {
        return null;
      }

      return response;
    } catch (error) {
      lastFailure = error is FetchFailure
          ? error
          : FetchFailure(
              totalDuration: stopwatch.elapsed,
              attemptCount: attemptCount,
              originalException: error,
              httpStatusCode: error is DioException
                  ? error.response?.statusCode
                  : null,
              uri: instructions.uri,
            );
      instructions = await strategy(instructions.uri, lastFailure);
      _debugCheckInstructions(instructions);
    }
  }
  final silent = instructions.silent ?? false;

  if (!silent && lastFailure != null) {
    throw lastFailure;
  } else {
    return null;
  }
}

const _defaultFetchStrategy = FetchStrategyBuilder(
  exponentialBackoffMultiplier: 2,
  initialPauseBetweenRetries: Duration(milliseconds: 500),
);

void _debugCheckInstructions(FetchInstructions? instructions) {
  // ignore: prefer_asserts_with_message
  assert(() {
    if (instructions == null) {
      throw StateError(
        'FetchInstructions must not be null. Check your fetch strategy.',
      );
    }
    return true;
  }());
}
