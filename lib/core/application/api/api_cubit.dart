// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/booru_factory.dart';

Dio dio(Directory dir, String baseUrl) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  dio.interceptors.add(
    DioCacheInterceptor(
      options: CacheOptions(
        store: HiveCacheStore(dir.path),
        maxStale: const Duration(days: 7),
        hitCacheOnErrorExcept: [],
      ),
    ),
  );

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
