// Package imports:
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoProvider {
  PackageInfoProvider(this.packageInfo);

  final PackageInfo packageInfo;

  PackageInfo getPackageInfo() => packageInfo;
}

Future<PackageInfo> getPackageInfo() => PackageInfo.fromPlatform();
