// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

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

const kEnvironment = String.fromEnvironment('ENV_NAME');

final currentEnvironmentProvider = Provider<String>((ref) {
  return kEnvironment;
});

final isDevEnvironmentProvider = Provider<bool>((ref) {
  return ref.watch(currentEnvironmentProvider) == 'dev';
});

final appVersionProvider = Provider<Version?>((ref) {
  final packageInfo = ref.watch(packageInfoProvider);

  return packageInfo.parseVersion();
});

extension PackageInfoX on PackageInfo {
  Version? parseVersion() {
    try {
      return Version.parse(version);
    } catch (e) {
      return null;
    }
  }
}
