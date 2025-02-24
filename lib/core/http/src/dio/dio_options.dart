// Package imports:
import 'package:cookie_jar/cookie_jar.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../configs/config.dart';
import '../../../foundation/loggers.dart';
import '../../../proxy/proxy.dart';

class DioOptions {
  DioOptions({
    required this.cookieJar,
    required this.baseUrl,
    required this.userAgent,
    required this.authConfig,
    required this.loggerService,
    required this.booruFactory,
    required this.proxySettings,
  });

  final CookieJar cookieJar;
  final String baseUrl;
  final String userAgent;
  final BooruConfigAuth authConfig;
  final Logger loggerService;
  final BooruFactory booruFactory;
  final ProxySettings? proxySettings;
}
