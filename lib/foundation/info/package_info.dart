// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = Provider<PackageInfo>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'packageInfoProvider',
);

final dummyPackageInfoProvider = Provider<PackageInfo>((ref) {
  return PackageInfo(
    appName: 'Boorusama',
    packageName: 'com.degenk.boorusama',
    version: '1.0.0',
    buildNumber: '1',
  );
});

const _kDevEnvironment = 'dev';

const kEnvironment = appFlavor ?? _kDevEnvironment;

final currentEnvironmentProvider = Provider<String>((ref) {
  return kEnvironment;
});

final isDevEnvironmentProvider = Provider<bool>((ref) {
  return ref.watch(currentEnvironmentProvider) == _kDevEnvironment;
});

final appVersionProvider = Provider<Version?>((ref) {
  final packageInfo = ref.watch(packageInfoProvider);

  return Version.tryParse(packageInfo.version);
});
