// Dart imports:
import 'dart:io';

// Package imports:
import 'package:boorusama/core/infra/networks/dio_doh_interceptor.dart';
import 'package:boorusama/core/settings.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

// Project imports:
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

Dio dio(
  Directory dir,
  String baseUrl,
  UserAgentGenerator generator,
  DohOptions dohOptions,
) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'User-Agent': generator.generate(),
    },
  ));

  dio
    ..interceptors.add(LogInterceptor())
    ..httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: Duration(seconds: 10),
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );

  // if (dohOptions != DohOptions.none) {
  //   dio.interceptors.add(DohInterceptor.from(
  //     mapDohOptionToDnsProvider(dohOptions),
  //     type: DnsRecordType.A,
  //   ));
  //   // dio.httpClientAdapter = Http2Adapter();
  // }

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

DnsProvider mapDohOptionToDnsProvider(DohOptions dohOption) {
  switch (dohOption) {
    case DohOptions.cloudflare:
      return DnsProvider.cloudflare;
    case DohOptions.google:
      return DnsProvider.google;
    default:
      throw ArgumentError('Invalid DOH option: $dohOption');
  }
}
