// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../ddos/handler/types.dart';
import '../../../../proxy/types.dart';
import 'network_protocol_info.dart';

class DioOptions {
  DioOptions({
    required this.ddosProtectionHandler,
    required this.userAgent,
    required this.loggerService,
    required this.networkProtocolInfo,
    required this.baseUrl,
    this.proxySettings,
    this.skipCertificateVerification = false,
  });

  final HttpProtectionHandler ddosProtectionHandler;
  final String baseUrl;
  final String userAgent;
  final Logger loggerService;
  final NetworkProtocolInfo networkProtocolInfo;
  final ProxySettings? proxySettings;
  final bool skipCertificateVerification;
}
