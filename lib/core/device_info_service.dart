// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/platform.dart';

class DeviceInfoService {
  const DeviceInfoService({
    required DeviceInfoPlugin plugin,
  }) : _plugin = plugin;

  final DeviceInfoPlugin _plugin;

  //TODO: support other platforms
  Future<DeviceInfo> getDeviceInfo() async {
    if (isAndroid()) {
      return DeviceInfo(androidDeviceInfo: await _plugin.androidInfo);
    } else if (isIOS()) {
      return DeviceInfo(iosDeviceInfo: await _plugin.iosInfo);
    } else {
      return DeviceInfo.empty();
    }
  }
}

class DeviceInfo extends Equatable {
  const DeviceInfo({
    this.androidDeviceInfo,
    this.iosDeviceInfo,
  });

  factory DeviceInfo.empty() => const DeviceInfo();

  final AndroidDeviceInfo? androidDeviceInfo;
  final IosDeviceInfo? iosDeviceInfo;

  @override
  List<Object?> get props => [androidDeviceInfo, iosDeviceInfo];
}
