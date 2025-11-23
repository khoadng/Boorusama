import 'dart:async';

import 'package:dio/dio.dart';

import 'fetch_strategy.dart';

Future<Response<T>?> tryGetResponse<T>(
  Uri uri, {
  required Dio dio,
  CancelToken? cancelToken,
  FetchStrategyBuilder? fetchStrategy,
  void Function(int count, int total)? onReceiveProgress,
  Options? options,
}) async {
  if (cancelToken?.isCancelled ?? false) {
    throw DioException(
      requestOptions: RequestOptions(path: uri.toString()),
      type: DioExceptionType.cancel,
    );
  }
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
    if (cancelToken?.isCancelled ?? false) {
      throw DioException(
        requestOptions: RequestOptions(path: uri.toString()),
        type: DioExceptionType.cancel,
      );
    }
    try {
      final response = await dio.getUri<T>(
        instructions.uri,
        cancelToken: cancelToken,
        options: effectiveOptions.copyWith(
          receiveTimeout: instructions.timeout,
          validateStatus: (status) => status == 200,
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
