// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

// Project imports:
import 'package:boorusama/core/user_agent_generator.dart';
import 'package:boorusama/foundation/http/dio_logger_interceptor.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';

Dio dio(
  Directory dir,
  String? baseUrl,
  UserAgentGenerator generator,
  LoggerService logger,
) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl ?? '',
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

  dio.interceptors.add(
    LoggingInterceptor(
      logger: logger,
    ),
  );

  return dio;
}
