// Package imports:
import 'package:booru_clients/generated.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/http/client/types.dart';

void main() {
  group('NetworkProtocolInfo', () {
    group('protocol selection', () {
      test('uses HTTP/1.1 when proxy is configured', () {
        const info = NetworkProtocolInfo(
          customProtocol: NetworkProtocol.https_2_0,
          detectedProtocol: NetworkProtocol.https_2_0,
          hasProxy: true,
          platform: PlatformInfo.macOS(),
        );

        expect(info.shouldUseHttp2(), false);
      });

      test('uses HTTP/1.1 on Windows regardless of configuration', () {
        const info = NetworkProtocolInfo(
          customProtocol: null,
          detectedProtocol: NetworkProtocol.https_2_0,
          hasProxy: false,
          platform: PlatformInfo.windows(),
        );

        expect(info.shouldUseHttp2(), false);
      });

      test('custom protocol takes precedence over detected protocol', () {
        final cases = [
          (
            custom: NetworkProtocol.https_2_0,
            detected: NetworkProtocol.https_1_1,
            usesHttp2: true,
          ),
          (
            custom: NetworkProtocol.https_1_1,
            detected: NetworkProtocol.https_2_0,
            usesHttp2: false,
          ),
        ];

        for (final c in cases) {
          final info = NetworkProtocolInfo(
            customProtocol: c.custom,
            detectedProtocol: c.detected,
            hasProxy: false,
            platform: const PlatformInfo.macOS(),
          );

          expect(info.shouldUseHttp2(), c.usesHttp2);
        }
      });

      test('falls back to detected protocol when custom is not set', () {
        final cases = [
          (detected: NetworkProtocol.https_2_0, usesHttp2: true),
          (detected: NetworkProtocol.https_1_1, usesHttp2: false),
          (detected: null, usesHttp2: false),
        ];

        for (final c in cases) {
          final info = NetworkProtocolInfo(
            customProtocol: null,
            detectedProtocol: c.detected,
            hasProxy: false,
            platform: const PlatformInfo.macOS(),
          );

          expect(info.shouldUseHttp2(), c.usesHttp2);
        }
      });
    });

    group('adapter selection', () {
      test('uses native adapter on supported platforms', () {
        final cases = [
          const PlatformInfo.android(cronetAvailable: true),
          const PlatformInfo.ios(),
          const PlatformInfo.macOS(),
        ];

        for (final platform in cases) {
          final info = NetworkProtocolInfo(
            customProtocol: null,
            detectedProtocol: null,
            hasProxy: false,
            platform: platform,
          );

          expect(info.getAdapterType(), HttpClientAdapterType.nativeAdapter);
        }
      });

      test('uses default adapter when native is unavailable', () {
        final cases = [
          const PlatformInfo.android(),
          const PlatformInfo.windows(),
        ];

        for (final platform in cases) {
          final info = NetworkProtocolInfo(
            customProtocol: null,
            detectedProtocol: null,
            hasProxy: false,
            platform: platform,
          );

          expect(info.getAdapterType(), HttpClientAdapterType.defaultAdapter);
        }
      });

      test('uses HTTP/2 adapter when HTTP/2 protocol is selected', () {
        const info = NetworkProtocolInfo(
          customProtocol: NetworkProtocol.https_2_0,
          detectedProtocol: null,
          hasProxy: false,
          platform: PlatformInfo.macOS(),
        );

        expect(info.getAdapterType(), HttpClientAdapterType.http2);
      });

      test('uses default adapter when proxy is configured', () {
        const info = NetworkProtocolInfo(
          customProtocol: NetworkProtocol.https_2_0,
          detectedProtocol: null,
          hasProxy: true,
          platform: PlatformInfo.android(cronetAvailable: true),
        );

        expect(info.getAdapterType(), HttpClientAdapterType.defaultAdapter);
      });
    });
  });
}
