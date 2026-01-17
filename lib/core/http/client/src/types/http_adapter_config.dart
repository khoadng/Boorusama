// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../proxy/types.dart';
import 'network_protocol_info.dart';

sealed class HttpAdapterConfig extends Equatable {
  const HttpAdapterConfig();

  factory HttpAdapterConfig.fromContext({
    required NetworkProtocolInfo? protocolInfo,
    required ProxySettings? proxySettings,
    required Logger? logger,
    required String? userAgent,
    bool skipCertificateVerification = false,
  }) {
    if (proxySettings != null &&
        proxySettings.enable &&
        proxySettings.isValid) {
      return ProxyAdapterConfig(
        proxySettings: proxySettings,
        logger: logger,
      );
    }

    // If skipping certificate verification, use the default adapter with
    // custom certificate handling
    if (skipCertificateVerification) {
      return DefaultAdapterConfig(
        logger: logger,
        skipCertificateVerification: true,
      );
    }

    final adapterType =
        protocolInfo?.getAdapterType() ?? HttpClientAdapterType.defaultAdapter;

    return switch (adapterType) {
      HttpClientAdapterType.http2 => Http2AdapterConfig(logger: logger),
      HttpClientAdapterType.nativeAdapter => NativeAdapterConfig(
        userAgent: userAgent,
        logger: logger,
      ),
      HttpClientAdapterType.defaultAdapter => DefaultAdapterConfig(
        logger: logger,
      ),
    };
  }
}

class DefaultAdapterConfig extends HttpAdapterConfig {
  const DefaultAdapterConfig({
    required this.logger,
    this.skipCertificateVerification = false,
  });

  final Logger? logger;
  final bool skipCertificateVerification;

  @override
  List<Object?> get props => [logger, skipCertificateVerification];
}

class ProxyAdapterConfig extends HttpAdapterConfig {
  const ProxyAdapterConfig({
    required this.proxySettings,
    required this.logger,
  });

  final ProxySettings proxySettings;
  final Logger? logger;

  @override
  List<Object?> get props => [proxySettings, logger];
}

class NativeAdapterConfig extends HttpAdapterConfig {
  const NativeAdapterConfig({
    required this.userAgent,
    required this.logger,
  });

  final String? userAgent;
  final Logger? logger;

  @override
  List<Object?> get props => [userAgent, logger];
}

class Http2AdapterConfig extends HttpAdapterConfig {
  const Http2AdapterConfig({
    required this.logger,
  });

  final Logger? logger;

  @override
  List<Object?> get props => [logger];
}
