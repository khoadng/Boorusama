// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../boorus/booru/booru.dart';
import '../../../configs/config.dart';
import '../../../ddos_solver/protection_handler.dart';
import '../../../proxy/proxy.dart';

class DioOptions {
  DioOptions({
    required this.ddosProtectionHandler,
    required this.baseUrl,
    required this.userAgent,
    required this.authConfig,
    required this.loggerService,
    required this.booruDb,
    required this.proxySettings,
    required this.cronetAvailable,
  });

  final HttpProtectionHandler ddosProtectionHandler;
  final String baseUrl;
  final String userAgent;
  final BooruConfigAuth authConfig;
  final Logger loggerService;
  final BooruDb booruDb;
  final ProxySettings? proxySettings;
  final bool cronetAvailable;
}
