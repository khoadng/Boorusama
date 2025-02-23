// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/widgets.dart';

Future<Response<List<int>>?> tryGetResponse(
  Uri resolved,
  StreamController<ImageChunkEvent>? chunkEvents, {
  required Dio dio,
  CancellationToken? cancelToken,
  Map<String, String>? headers,
  FetchStrategy? fetchStrategy,
}) async {
  cancelToken?.throwIfCancellationRequested();
  final stopwatch = Stopwatch()..start();
  final builder = fetchStrategy ?? _defaultFetchStrategy;
  var instructions = await builder(resolved, null);
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
          : FetchFailure._(
              totalDuration: stopwatch.elapsed,
              attemptCount: attemptCount,
              originalException: error,
              httpStatusCode:
                  error is DioException ? error.response?.statusCode : null,
              uri: instructions.uri,
            );
      instructions = await builder(instructions.uri, lastFailure);
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

bool _defaultTransientHttpStatusCodePredicate(int statusCode) {
  return defaultTransientHttpStatusCodes.contains(statusCode);
}

const List<int> defaultTransientHttpStatusCodes = [
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
            failure.attemptCount > maxAttempts) {
          return FetchInstructions.giveUp(uri: uri, silent: silent);
        }

        final Duration pauseBetweenRetries = initialPauseBetweenRetries *
            math.pow(exponentialBackoffMultiplier, failure.attemptCount - 1);

        await Future.delayed(pauseBetweenRetries);

        return FetchInstructions.attempt(uri: uri, timeout: timeout);
      };
}

typedef FetchStrategy = Future<FetchInstructions> Function(
    Uri uri, FetchFailure? failure);

@immutable
class FetchInstructions {
  const FetchInstructions.giveUp({
    required this.uri,
    this.silent,
    this.alternativeImage,
  })  : shouldGiveUp = true,
        timeout = Duration.zero;

  const FetchInstructions.attempt({
    required this.uri,
    required this.timeout,
  })  : shouldGiveUp = false,
        silent = null,
        alternativeImage = null;

  final bool shouldGiveUp;
  final Duration timeout;
  final Uri uri;
  final Future<ui.Image>? alternativeImage;
  final bool? silent;

  @override
  String toString() {
    return 'FetchInstructions(shouldGiveUp: $shouldGiveUp, timeout: $timeout, uri: $uri, slilent: $silent)';
  }
}

@immutable
class FetchFailure implements Exception {
  const FetchFailure._({
    required this.totalDuration,
    required this.attemptCount,
    this.httpStatusCode,
    this.uri,
    this.originalException,
  }) : assert(attemptCount > 0);

  final Duration totalDuration;
  final int attemptCount;
  final int? httpStatusCode;
  final Uri? uri;
  final dynamic originalException;

  get isRetriableFailure =>
      (httpStatusCode != null &&
          _defaultTransientHttpStatusCodePredicate(httpStatusCode!)) ||
      originalException is SocketException;

  @override
  String toString() {
    return 'FetchFailure: attemptCount: $attemptCount, httpStatusCode: $httpStatusCode, uri: $uri, totalDuration: $totalDuration, originalException: $originalException';
  }
}

final _defaultFetchStrategy = const FetchStrategyBuilder(
  exponentialBackoffMultiplier: 2,
  initialPauseBetweenRetries: Duration(milliseconds: 500),
).build();

void _debugCheckInstructions(FetchInstructions? instructions) {
  assert(() {
    if (instructions == null) {
      throw StateError(
          'FetchInstructions must not be null. Check your fetch strategy.');
    }
    return true;
  }());
}
