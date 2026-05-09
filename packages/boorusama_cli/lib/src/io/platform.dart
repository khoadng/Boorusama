import 'dart:io';

enum HostPlatform { macos, linux, windows, unknown }

HostPlatform currentHostPlatform() {
  if (Platform.isMacOS) return HostPlatform.macos;
  if (Platform.isLinux) return HostPlatform.linux;
  if (Platform.isWindows) return HostPlatform.windows;
  return HostPlatform.unknown;
}

extension HostPlatformName on HostPlatform {
  String get label => switch (this) {
    HostPlatform.macos => 'macos',
    HostPlatform.linux => 'linux',
    HostPlatform.windows => 'windows',
    HostPlatform.unknown => 'unknown',
  };
}
