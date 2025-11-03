// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../boorus/booru/types.dart';
import '../../../../configs/config/types.dart';
import '../../../../ddos/handler/types.dart';
import '../../../../proxy/types.dart';

class DioOptions {
  DioOptions({
    required this.ddosProtectionHandler,
    required this.userAgent,
    required this.authConfig,
    required this.loggerService,
    required this.booruDb,
    required this.cronetAvailable,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? authConfig.url,
       proxySettings = authConfig.proxySettings;

  final HttpProtectionHandler ddosProtectionHandler;
  final String baseUrl;
  final String userAgent;
  final BooruConfigAuth authConfig;
  final Logger loggerService;
  final BooruDb booruDb;
  final ProxySettings? proxySettings;
  final bool cronetAvailable;
}
