// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

// Project imports:
import 'package:boorusama/core/domain/user_agent_generator.dart';

Dio dio(Directory dir, String baseUrl, UserAgentGenerator generator) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'User-Agent': generator.generate(),
    },
  ));

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
