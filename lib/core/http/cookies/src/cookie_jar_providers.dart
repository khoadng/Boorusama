// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'cookie_jar_factory.dart';

final cookieJarFactoryProvider = Provider<CookieJarFactory>(
  (_) => throw UnimplementedError(
    'cookieJarFactoryProvider must be overridden',
  ),
);

final cookieJarProvider = Provider<LazyAsync<CookieJar>>((ref) {
  final factory = ref.watch(cookieJarFactoryProvider);
  return LazyAsync(factory.create);
});
