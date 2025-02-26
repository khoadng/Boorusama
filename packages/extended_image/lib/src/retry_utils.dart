// Dart imports:
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/widgets.dart';

import 'fetch_strategy.dart';

Future<Response<List<int>>?> tryGetResponse(
  Uri resolved,
  StreamController<ImageChunkEvent>? chunkEvents, {
  required Dio dio,
  CancellationToken? cancelToken,
  Map<String, String>? headers,
  FetchStrategyBuilder? fetchStrategy,
}) async {
  cancelToken?.throwIfCancellationRequested();
  final stopwatch = Stopwatch()..start();
  final builder = fetchStrategy ?? _defaultFetchStrategy;
  final strategy = builder.build();
  var instructions = await strategy(resolved, null);
  _debugCheckInstructions(instructions);
  var attemptCount = 0;
  FetchFailure? lastFailure;

  while (!instructions.shouldGiveUp) {
    attemptCount++;
    cancelToken?.throwIfCancellationRequested();
    try {
      final response = await dio.getUri<List<int>>(
        instructions.uri,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
          receiveTimeout: instructions.timeout,
          validateStatus: (status) => status == HttpStatus.ok,
        ),
        onReceiveProgress: chunkEvents != null
            ? (count, total) {
                if (!chunkEvents.isClosed && total >= 0) {
                  chunkEvents.add(
                    ImageChunkEvent(
                      cumulativeBytesLoaded: count,
                      expectedTotalBytes: total,
                    ),
                  );
                }
              }
            : null,
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
              httpStatusCode:
                  error is DioException ? error.response?.statusCode : null,
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

final _defaultFetchStrategy = const FetchStrategyBuilder(
  exponentialBackoffMultiplier: 2,
  initialPauseBetweenRetries: Duration(milliseconds: 500),
);

void _debugCheckInstructions(FetchInstructions? instructions) {
  assert(() {
    if (instructions == null) {
      throw StateError(
          'FetchInstructions must not be null. Check your fetch strategy.');
    }
    return true;
  }());
}
