// Package imports:
import 'package:booru_clients/generated.dart';

// Project imports:
import '../../../../../foundation/platform.dart' as platform_utils;

class NetworkProtocolInfo {
  const NetworkProtocolInfo({
    required this.customProtocol,
    required this.detectedProtocol,
    required this.platform,
  });

  /// Creates a NetworkProtocolInfo for generic HTTP clients without proxy
  factory NetworkProtocolInfo.generic({bool? cronetAvailable}) {
    return NetworkProtocolInfo(
      customProtocol: null,
      detectedProtocol: null,
      platform: PlatformInfo.fromCurrent(
        cronetAvailable: cronetAvailable,
      ),
    );
  }

  /// User-specified protocol override (null = auto-detect)
  final NetworkProtocol? customProtocol;

  /// Protocol detected from booru configuration
  final NetworkProtocol? detectedProtocol;

  /// Current platform
  final PlatformInfo platform;

  /// Determines which HTTP client adapter type to use
  HttpClientAdapterType getAdapterType() {
    return switch (customProtocol) {
      NetworkProtocol.https_2_0 => HttpClientAdapterType.http2,
      NetworkProtocol.https_1_1 => HttpClientAdapterType.defaultAdapter,
      null => switch ((detectedProtocol, platform)) {
        // Android with Cronet available
        (_, PlatformInfo(:final isAndroid, :final cronetAvailable))
            when isAndroid && cronetAvailable =>
          HttpClientAdapterType.nativeAdapter,

        // iOS always uses native adapter
        (_, PlatformInfo(:final isIOS)) when isIOS =>
          HttpClientAdapterType.nativeAdapter,

        // macOS always uses native adapter
        (_, PlatformInfo(:final isMacOS)) when isMacOS =>
          HttpClientAdapterType.nativeAdapter,

        // HTTP/2 on supported platforms
        (
          NetworkProtocol.https_2_0,
          PlatformInfo(:final isWindows, :final isWeb),
        )
            when !isWindows && !isWeb =>
          HttpClientAdapterType.http2,

        // All other cases: Windows, Web, Android without Cronet, or HTTP/1.1
        _ => HttpClientAdapterType.defaultAdapter,
      },
    };
  }
}

enum HttpClientAdapterType {
  defaultAdapter,
  nativeAdapter,
  http2,
}

/// Platform information for protocol selection
class PlatformInfo {
  const PlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    required this.isMacOS,
    required this.isWindows,
    required this.isWeb,
    required this.cronetAvailable,
  });

  factory PlatformInfo.fromCurrent({bool? cronetAvailable}) {
    return PlatformInfo(
      isAndroid: platform_utils.isAndroid(),
      isIOS: platform_utils.isIOS(),
      isMacOS: platform_utils.isMacOS(),
      isWindows: platform_utils.isWindows(),
      isWeb: platform_utils.isWeb(),
      cronetAvailable: cronetAvailable ?? false,
    );
  }

  const PlatformInfo.android({this.cronetAvailable = false})
    : isAndroid = true,
      isIOS = false,
      isMacOS = false,
      isWeb = false,
      isWindows = false;

  const PlatformInfo.ios()
    : isAndroid = false,
      isIOS = true,
      isMacOS = false,
      isWindows = false,
      isWeb = false,
      cronetAvailable = false;

  const PlatformInfo.macOS()
    : isAndroid = false,
      isIOS = false,
      isMacOS = true,
      isWindows = false,
      isWeb = false,
      cronetAvailable = false;

  const PlatformInfo.windows()
    : isAndroid = false,
      isIOS = false,
      isMacOS = false,
      isWindows = true,
      isWeb = false,
      cronetAvailable = false;

  final bool isAndroid;
  final bool isIOS;
  final bool isMacOS;
  final bool isWindows;
  final bool isWeb;
  final bool cronetAvailable;

  bool get canUseNativeAdapter {
    if (isAndroid || isIOS || isMacOS) return true;
    return false;
  }

  bool get shouldUseCronetOnAndroid {
    return isAndroid && cronetAvailable;
  }
}
