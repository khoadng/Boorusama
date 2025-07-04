import 'package:foundation/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../foundation/info/app_info.dart';
import 'http_utils.dart';

class CustomHttpHeaders {
  const CustomHttpHeaders({
    required this.userAgent,
    required this.headers,
  });

  const CustomHttpHeaders.empty()
      : userAgent = '',
        headers = const {};

  factory CustomHttpHeaders.defaults(
    PackageInfo packageInfo,
    AppInfo appInfo, {
    required Map<String, String> headers,
  }) {
    return CustomHttpHeaders(
      userAgent: createDefaultUserAgent(packageInfo, appInfo),
      headers: headers,
    );
  }
  final String userAgent;
  final Map<String, String> headers;

  String getUserAgent() => headers[AppHttpHeaders.userAgentHeader] ?? userAgent;

  Map<String, String> toMap() {
    return {
      AppHttpHeaders.userAgentHeader: userAgent,
      ...headers,
    };
  }
}

String createDefaultUserAgent(
  PackageInfo packageInfo,
  AppInfo appInfo,
) {
  final appVersion = packageInfo.version;
  final appName = appInfo.appName;

  return '${appName.sentenceCase}/$appVersion';
}
