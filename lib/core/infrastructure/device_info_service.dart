// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

class DeviceInfoService {
  const DeviceInfoService({
    required DeviceInfoPlugin plugin,
  }) : _plugin = plugin;

  final DeviceInfoPlugin _plugin;

  //TODO: support other platforms
  Future<DeviceInfo> getDeviceInfo() async {
    if (isAndroid()) {
      return _plugin.androidInfo.then((value) => DeviceInfo(
            versionCode: value.version.sdkInt ?? 0,
            release: value.version.release ?? '',
          ));
    } else if (isWeb()) {
      return _plugin.webBrowserInfo.then((value) => DeviceInfo(
            versionCode: -1,
            release: value.browserName.name,
          ));
    } else {
      return DeviceInfo.empty();
    }
  }
}

class DeviceInfo extends Equatable {
  const DeviceInfo({
    required this.versionCode,
    required this.release,
  });

  factory DeviceInfo.empty() => const DeviceInfo(versionCode: -1, release: '');

  final int versionCode;
  final String release;

  @override
  List<Object?> get props => [versionCode, release];
}
