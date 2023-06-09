// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

export 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = Provider<PackageInfo>((ref) {
  throw UnimplementedError();
});

final dummyPackageInfoProvider = Provider<PackageInfo>((ref) {
  return PackageInfo(
    appName: 'Boorusama',
    packageName: 'com.degenk.boorusama',
    version: '1.0.0',
    buildNumber: '1',
  );
});
