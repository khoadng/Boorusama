// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../platform.dart';

final deviceInfoProvider = Provider<DeviceInfo>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'deviceInfoProvider',
);

class DeviceInfoService {
  const DeviceInfoService({
    required DeviceInfoPlugin plugin,
  }) : _plugin = plugin;

  final DeviceInfoPlugin _plugin;

  Future<DeviceInfo> getDeviceInfo() async {
    if (isAndroid()) {
      return DeviceInfo(androidDeviceInfo: await _plugin.androidInfo);
    } else if (isIOS()) {
      return DeviceInfo(iosDeviceInfo: await _plugin.iosInfo);
    } else if (isMacOS()) {
      return DeviceInfo(macOsDeviceInfo: await _plugin.macOsInfo);
    } else if (isWeb()) {
      return DeviceInfo(webBrowserInfo: await _plugin.webBrowserInfo);
    } else if (isWindows()) {
      return DeviceInfo(windowsDeviceInfo: await _plugin.windowsInfo);
    } else if (isLinux()) {
      return DeviceInfo(linuxDeviceInfo: await _plugin.linuxInfo);
    } else {
      return DeviceInfo.empty();
    }
  }
}

class DeviceInfo extends Equatable {
  const DeviceInfo({
    this.androidDeviceInfo,
    this.iosDeviceInfo,
    this.macOsDeviceInfo,
    this.webBrowserInfo,
    this.windowsDeviceInfo,
    this.linuxDeviceInfo,
  });

  factory DeviceInfo.empty() => const DeviceInfo();

  final AndroidDeviceInfo? androidDeviceInfo;
  final IosDeviceInfo? iosDeviceInfo;
  final MacOsDeviceInfo? macOsDeviceInfo;
  final WebBrowserInfo? webBrowserInfo;
  final WindowsDeviceInfo? windowsDeviceInfo;
  final LinuxDeviceInfo? linuxDeviceInfo;

  String? get deviceModel {
    if (androidDeviceInfo != null) {
      return androidDeviceInfo!.model;
    } else if (iosDeviceInfo != null) {
      return iosDeviceInfo!.model;
    } else if (macOsDeviceInfo != null) {
      return macOsDeviceInfo!.model;
    } else if (webBrowserInfo != null) {
      return webBrowserInfo!.product;
    } else if (windowsDeviceInfo != null) {
      return windowsDeviceInfo!.productName;
    } else if (linuxDeviceInfo != null) {
      return linuxDeviceInfo!.name;
    } else {
      return 'Unknown platform';
    }
  }

  String? get deviceName {
    if (androidDeviceInfo != null) {
      return '${androidDeviceInfo!.brand} (${androidDeviceInfo!.model})';
    } else if (iosDeviceInfo != null) {
      return iosDeviceInfo!.name;
    } else if (macOsDeviceInfo != null) {
      return macOsDeviceInfo!.computerName;
    } else if (webBrowserInfo != null) {
      return null;
    } else if (windowsDeviceInfo != null) {
      return windowsDeviceInfo!.computerName;
    } else if (linuxDeviceInfo != null) {
      return linuxDeviceInfo!.name;
    } else {
      return 'Unknown platform';
    }
  }

  String dump() {
    if (androidDeviceInfo != null) {
      return androidDeviceInfo!.data.toString();
    } else if (iosDeviceInfo != null) {
      return iosDeviceInfo!.data.toString();
    } else if (macOsDeviceInfo != null) {
      return macOsDeviceInfo!.data.toString();
    } else if (webBrowserInfo != null) {
      return webBrowserInfo!.data.toString();
    } else if (windowsDeviceInfo != null) {
      return windowsDeviceInfo!.data.toString();
    } else if (linuxDeviceInfo != null) {
      return linuxDeviceInfo!.data.toString();
    } else {
      return 'Unknown platform';
    }
  }

  @override
  List<Object?> get props => [
        androidDeviceInfo,
        iosDeviceInfo,
        macOsDeviceInfo,
        webBrowserInfo,
        windowsDeviceInfo,
        linuxDeviceInfo,
      ];
}
