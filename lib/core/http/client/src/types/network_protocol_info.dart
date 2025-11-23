// Package imports:
import 'package:booru_clients/generated.dart';

// Project imports:
import '../../../../../foundation/platform.dart' as platform_utils;

class NetworkProtocolInfo {
  const NetworkProtocolInfo({
    required this.customProtocol,
    required this.detectedProtocol,
    required this.hasProxy,
    required this.platform,
  });

  /// Creates a NetworkProtocolInfo for generic HTTP clients without proxy
  factory NetworkProtocolInfo.generic({bool? cronetAvailable}) {
    return NetworkProtocolInfo(
      customProtocol: null,
      detectedProtocol: null,
      hasProxy: false,
      platform: PlatformInfo.fromCurrent(
        cronetAvailable: cronetAvailable,
      ),
    );
  }

  /// User-specified protocol override (null = auto-detect)
  final NetworkProtocol? customProtocol;

  /// Protocol detected from booru configuration
  final NetworkProtocol? detectedProtocol;

  /// Whether proxy is enabled
  final bool hasProxy;

  /// Current platform
  final PlatformInfo platform;

  /// Determines whether HTTP/2 should be used based on all conditions
  bool shouldUseHttp2() {
    // Proxy always forces default adapter (HTTP/1.1)
    if (hasProxy) return false;

    // Windows/Web doesn't support HTTP/2 adapter
    if (platform.isWindows || platform.isWeb) return false;

    // User override takes precedence
    if (customProtocol != null) {
      return customProtocol == NetworkProtocol.https_2_0;
    }

    // Fall back to detected protocol
    return detectedProtocol == NetworkProtocol.https_2_0;
  }

  /// Determines which HTTP client adapter type to use
  HttpClientAdapterType getAdapterType() {
    // Proxy requires default adapter with custom HttpClient
    if (hasProxy) return HttpClientAdapterType.defaultAdapter;

    // HTTP/2 support
    if (shouldUseHttp2()) return HttpClientAdapterType.http2;

    // Native adapter for mobile/macOS without proxy
    if (platform.canUseNativeAdapter) {
      // On Android, check if Cronet is available
      if (platform.isAndroid) {
        return platform.shouldUseCronetOnAndroid
            ? HttpClientAdapterType.nativeAdapter
            : HttpClientAdapterType.defaultAdapter;
      }
      return HttpClientAdapterType.nativeAdapter;
    }

    // Default fallback
    return HttpClientAdapterType.defaultAdapter;
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
