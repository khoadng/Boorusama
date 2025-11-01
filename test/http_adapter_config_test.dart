// Package imports:
import 'package:booru_clients/generated.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/http/src/dio/http_adapter_config.dart';
import 'package:boorusama/core/http/src/dio/network_protocol_info.dart';
import 'package:boorusama/core/proxy/types.dart';

void main() {
  group('HttpAdapterConfig', () {
    group('proxy settings', () {
      test('selects default adapter when proxy is enabled', () {
        const proxySettings = ProxySettings(
          host: 'localhost',
          port: 1080,
          type: ProxyType.socks5,
        );

        final config = HttpAdapterConfig.fromContext(
          protocolInfo: null,
          proxySettings: proxySettings,
          logger: null,
          userAgent: null,
        );

        expect(config, isA<DefaultAdapterConfig>());
        expect((config as DefaultAdapterConfig).proxyConfig, isNotNull);
      });

      test('passes proxy credentials to adapter config', () {
        const proxySettings = ProxySettings(
          host: 'proxy.example.com',
          port: 8080,
          type: ProxyType.http,
          username: 'user',
          password: 'pass',
        );

        final config = HttpAdapterConfig.fromContext(
          protocolInfo: null,
          proxySettings: proxySettings,
          logger: null,
          userAgent: null,
        );

        final proxyConfig = (config as DefaultAdapterConfig).proxyConfig;
        expect(
          proxyConfig,
          const ProxyConfig(
            type: ProxyType.http,
            host: 'proxy.example.com',
            port: 8080,
            username: 'user',
            password: 'pass',
          ),
        );
      });

      test('prioritizes proxy over protocol settings', () {
        const proxySettings = ProxySettings(
          host: 'localhost',
          port: 1080,
          type: ProxyType.socks5,
        );

        const protocolInfo = NetworkProtocolInfo(
          customProtocol: NetworkProtocol.https_2_0,
          detectedProtocol: NetworkProtocol.https_2_0,
          hasProxy: false,
          platform: PlatformInfo.macOS(),
        );

        final config = HttpAdapterConfig.fromContext(
          protocolInfo: protocolInfo,
          proxySettings: proxySettings,
          logger: null,
          userAgent: null,
        );

        expect(config, isA<DefaultAdapterConfig>());
      });

      test('ignores disabled proxy', () {
        const proxySettings = ProxySettings(
          enable: false,
          host: 'localhost',
          port: 1080,
          type: ProxyType.socks5,
        );

        final config = HttpAdapterConfig.fromContext(
          protocolInfo: null,
          proxySettings: proxySettings,
          logger: null,
          userAgent: null,
        );

        expect((config as DefaultAdapterConfig).proxyConfig, isNull);
      });
    });

    group('protocol-based adapter selection', () {
      test('selects HTTP/2 adapter when protocol requires it', () {
        const protocolInfo = NetworkProtocolInfo(
          customProtocol: NetworkProtocol.https_2_0,
          detectedProtocol: null,
          hasProxy: false,
          platform: PlatformInfo.macOS(),
        );

        final config = HttpAdapterConfig.fromContext(
          protocolInfo: protocolInfo,
          proxySettings: null,
          logger: null,
          userAgent: null,
        );

        expect(config, isA<Http2AdapterConfig>());
      });
    });

    group('platform-based adapter selection', () {
      final nativeAdapterCases = [
        (
          platform: const PlatformInfo.android(cronetAvailable: true),
          description: 'Android with Cronet',
        ),
        (
          platform: const PlatformInfo.ios(),
          description: 'iOS',
        ),
        (
          platform: const PlatformInfo.macOS(),
          description: 'macOS',
        ),
      ];

      for (final testCase in nativeAdapterCases) {
        test('selects native adapter on ${testCase.description}', () {
          final protocolInfo = NetworkProtocolInfo(
            customProtocol: null,
            detectedProtocol: null,
            hasProxy: false,
            platform: testCase.platform,
          );

          final config = HttpAdapterConfig.fromContext(
            protocolInfo: protocolInfo,
            proxySettings: null,
            logger: null,
            userAgent: 'TestAgent',
          );

          expect(config, isA<NativeAdapterConfig>());
        });
      }

      final defaultAdapterCases = [
        (
          platform: const PlatformInfo.android(),
          description: 'Android without Cronet',
        ),
        (
          platform: const PlatformInfo.windows(),
          description: 'Windows',
        ),
      ];

      for (final testCase in defaultAdapterCases) {
        test('selects default adapter on ${testCase.description}', () {
          final protocolInfo = NetworkProtocolInfo(
            customProtocol: null,
            detectedProtocol: null,
            hasProxy: false,
            platform: testCase.platform,
          );

          final config = HttpAdapterConfig.fromContext(
            protocolInfo: protocolInfo,
            proxySettings: null,
            logger: null,
            userAgent: null,
          );

          expect(config, isA<DefaultAdapterConfig>());
          expect((config as DefaultAdapterConfig).proxyConfig, isNull);
        });
      }

      test('selects default adapter when protocol info is null', () {
        final config = HttpAdapterConfig.fromContext(
          protocolInfo: null,
          proxySettings: null,
          logger: null,
          userAgent: null,
        );

        expect(config, isA<DefaultAdapterConfig>());
        expect((config as DefaultAdapterConfig).proxyConfig, isNull);
      });
    });
  });
}
