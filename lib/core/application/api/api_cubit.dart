// Dart imports:
import 'dart:io';
import 'dart:math';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/booru_factory.dart';

const maxRetry = 7;

List<Duration> exponentialBackoff(int retries) =>
    [for (var i = 0; i < retries; i += 1) i]
        .map((count) => pow(2, count))
        .map((e) => Duration(seconds: e.toInt()))
        .toList();

Dio dio(Directory dir, String baseUrl) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  dio.interceptors.add(
    DioCacheInterceptor(
        options: CacheOptions(
      store: HiveCacheStore(dir.path),
      maxStale: const Duration(days: 7),
      hitCacheOnErrorExcept: [],
    )),
  );

  dio.interceptors.add(RetryInterceptor(
    dio: dio,
    logPrint: print,
    retries: maxRetry,
    retryEvaluator: (error, attempt) =>
        ![500, 422].contains(error.response?.statusCode),
    retryDelays: exponentialBackoff(maxRetry),
  ));

  return dio;
}

class ApiEndpointState extends Equatable {
  const ApiEndpointState({
    required this.booru,
  });

  final Booru booru;

  @override
  List<Object?> get props => [booru];
}

class ApiEndpointCubit extends Cubit<ApiEndpointState> {
  ApiEndpointCubit({
    required Booru initialValue,
    required this.factory,
  }) : super(ApiEndpointState(booru: initialValue));

  final BooruFactory factory;

  void changeApi({
    required bool isSafeMode,
  }) {
    final booru = factory.create(
      isSafeMode: isSafeMode,
    );

    emit(ApiEndpointState(
      booru: booru,
    ));
  }
}

class ApiState extends Equatable {
  const ApiState({
    required this.api,
    required this.dio,
  });
  factory ApiState.initial(Dio dio) => ApiState(
        api: Api(dio),
        dio: dio,
      );

  final Api api;
  final Dio dio;

  ApiState copyWith({
    Api? api,
    Dio? dio,
  }) =>
      ApiState(
        api: api ?? this.api,
        dio: dio ?? this.dio,
      );

  @override
  List<Object?> get props => [api];
}

class ApiCubit extends Cubit<ApiState> {
  ApiCubit({
    required String defaultUrl,
    required Dio Function(String baseUrl) onDioRequest,
  })  : _onDioRequest = onDioRequest,
        super(ApiState.initial(onDioRequest(defaultUrl)));

  final Dio Function(String baseUrl) _onDioRequest;

  void changeApi(Booru booru) {
    final dio = _onDioRequest(booru.url);
    emit(state.copyWith(
      api: Api(dio),
      dio: dio,
    ));
  }
}
