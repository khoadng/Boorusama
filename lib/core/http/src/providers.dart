// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../boorus/booru/booru.dart';
import '../../boorus/booru/providers.dart';
import '../../configs/config.dart';
import '../../foundation/loggers.dart';
import '../../foundation/platform.dart';
import '../../info/app_info.dart';
import '../../info/package_info.dart';
import 'cookie_jar_providers.dart';
import 'dio/dio.dart';
import 'dio/dio_options.dart';

final dioProvider = Provider.family<Dio, BooruConfigAuth>((ref, config) {
  final cookieJar = ref.watch(cookieJarProvider);
  final userAgent = ref.watch(userAgentProvider(config.booruType));
  final loggerService = ref.watch(loggerProvider);
  final booruFactory = ref.watch(booruFactoryProvider);
  final cronetAvailable = ref.watch(isGooglePlayServiceAvailableProvider);

  return newDio(
    options: DioOptions(
      cookieJar: cookieJar,
      baseUrl: config.url,
      userAgent: userAgent,
      authConfig: config,
      loggerService: loggerService,
      booruFactory: booruFactory,
      proxySettings: config.proxySettings,
      cronetAvailable: cronetAvailable,
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
