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
  }) {
    final proxyConfig = _extractProxyConfig(proxySettings);

    if (proxyConfig != null) {
      return DefaultAdapterConfig(
        proxyConfig: proxyConfig,
        logger: logger,
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
        proxyConfig: null,
        logger: logger,
      ),
    };
  }

  static ProxyConfig? _extractProxyConfig(ProxySettings? settings) {
    if (settings == null || !settings.enable) return null;

    final address = settings.getProxyAddress();
    if (address == null) return null;

    return ProxyConfig(
      type: settings.type,
      host: settings.host,
      port: settings.port,
      username: settings.username,
      password: settings.password,
    );
  }
}

class DefaultAdapterConfig extends HttpAdapterConfig {
  const DefaultAdapterConfig({
    required this.proxyConfig,
    required this.logger,
  });

  final ProxyConfig? proxyConfig;
  final Logger? logger;

  @override
  List<Object?> get props => [proxyConfig, logger];
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

class ProxyConfig extends Equatable {
  const ProxyConfig({
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  final ProxyType type;
  final String host;
  final int port;
  final String? username;
  final String? password;

  @override
  List<Object?> get props => [type, host, port, username, password];
}
