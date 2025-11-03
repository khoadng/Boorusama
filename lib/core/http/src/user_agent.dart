// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import '../../../foundation/info/app_info.dart';
import '../../../foundation/info/package_info.dart';

final defaultUserAgentProvider = Provider.autoDispose<String>((ref) {
  final appInfo = ref.watch(appInfoProvider);
  final packageInfo = ref.watch(packageInfoProvider);

  return getDefaultUserAgent(appInfo, packageInfo);
});

String getDefaultUserAgent(AppInfo appInfo, PackageInfo packageInfo) {
  final appName = appInfo.appName;
  final appVersion = packageInfo.version;

  return '${appName.sentenceCase}/$appVersion';
}
