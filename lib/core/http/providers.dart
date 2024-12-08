// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/http/dio_options.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/loggers.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'dio.dart';

final dioProvider = Provider.family<Dio, BooruConfigAuth>((ref, config) {
  final cacheDir = ref.watch(httpCacheDirProvider);
  final userAgent = ref.watch(userAgentProvider(config.booruType));
  final loggerService = ref.watch(loggerProvider);
  final booruFactory = ref.watch(booruFactoryProvider);

  return newDio(
    options: DioOptions(
      cacheDir: cacheDir,
      baseUrl: config.url,
      userAgent: userAgent,
      authConfig: config,
      loggerService: loggerService,
      booruFactory: booruFactory,
    ),
  );
});

final userAgentProvider = Provider.family<String, BooruType>(
  (ref, booruType) {
    final appVersion = ref.watch(packageInfoProvider).version;
    final appName = ref.watch(appInfoProvider).appName;

    return switch (booruType) {
      BooruType.zerochan => '${appName.sentenceCase}/$appVersion - boorusama',
      _ => '${appName.sentenceCase}/$appVersion',
    };
  },
);

final httpCacheDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(),
  name: 'httpCacheDirProvider',
);
