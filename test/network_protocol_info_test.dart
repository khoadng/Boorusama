// Package imports:
import 'package:booru_clients/generated.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/http/client/types.dart';

void main() {
  group('NetworkProtocolInfo', () {
    group('adapter selection', () {
      final cases = [
        // Custom protocol overrides everything
        (
          customProtocol: NetworkProtocol.https_2_0,
          detectedProtocol: null,
          platform: const PlatformInfo.windows(),
          expected: HttpClientAdapterType.http2,
        ),
        (
          customProtocol: NetworkProtocol.https_1_1,
          detectedProtocol: NetworkProtocol.https_2_0,
          platform: const PlatformInfo.ios(),
          expected: HttpClientAdapterType.defaultAdapter,
        ),

        // Detected HTTP/2 on supported platforms
        (
          customProtocol: null,
          detectedProtocol: NetworkProtocol.https_2_0,
          platform: const PlatformInfo.macOS(),
          expected: HttpClientAdapterType.http2,
        ),

        // Windows/Web use default adapter with detected HTTP/2
        (
          customProtocol: null,
          detectedProtocol: NetworkProtocol.https_2_0,
          platform: const PlatformInfo.windows(),
          expected: HttpClientAdapterType.defaultAdapter,
        ),

        // Native adapter cases
        (
          customProtocol: null,
          detectedProtocol: null,
          platform: const PlatformInfo.android(cronetAvailable: true),
          expected: HttpClientAdapterType.nativeAdapter,
        ),
        (
          customProtocol: null,
          detectedProtocol: null,
          platform: const PlatformInfo.ios(),
          expected: HttpClientAdapterType.nativeAdapter,
        ),
        (
          customProtocol: null,
          detectedProtocol: NetworkProtocol.https_1_1,
          platform: const PlatformInfo.macOS(),
          expected: HttpClientAdapterType.nativeAdapter,
        ),

        // Default adapter cases
        (
          customProtocol: null,
          detectedProtocol: null,
          platform: const PlatformInfo.android(),
          expected: HttpClientAdapterType.defaultAdapter,
        ),
      ];

      for (final c in cases) {
        test(
          'returns ${c.expected.name} for protocol=${c.customProtocol?.name ?? c.detectedProtocol?.name ?? 'null'} on ${_platformName(c.platform)}',
          () {
            final info = NetworkProtocolInfo(
              customProtocol: c.customProtocol,
              detectedProtocol: c.detectedProtocol,
              platform: c.platform,
            );

            expect(info.getAdapterType(), c.expected);
          },
        );
      }
    });
  });
}

String _platformName(PlatformInfo platform) {
  return switch (platform) {
    PlatformInfo(:final isAndroid, :final cronetAvailable)
        when isAndroid && cronetAvailable =>
      'Android with Cronet',
    PlatformInfo(:final isAndroid) when isAndroid => 'Android without Cronet',
    PlatformInfo(:final isIOS) when isIOS => 'iOS',
    PlatformInfo(:final isMacOS) when isMacOS => 'macOS',
    PlatformInfo(:final isWindows) when isWindows => 'Windows',
    PlatformInfo(:final isWeb) when isWeb => 'Web',
    _ => 'Unknown',
  };
}
