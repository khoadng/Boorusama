// Package imports:
import 'package:foundation/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import '../../../foundation/info/app_info.dart';

String getDefaultUserAgent(AppInfo appInfo, PackageInfo packageInfo) {
  final appName = appInfo.appName;
  final appVersion = packageInfo.version;

  return '${appName.sentenceCase}/$appVersion';
}
