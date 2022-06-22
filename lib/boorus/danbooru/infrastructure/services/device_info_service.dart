// Dart imports:
import 'dart:io';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';

class DeviceInfoService {
  const DeviceInfoService({
    required DeviceInfoPlugin plugin,
  }) : _plugin = plugin;

  final DeviceInfoPlugin _plugin;

  Future<DeviceInfo> getDeviceInfo() async {
    if (Platform.isAndroid) {
      return _plugin.androidInfo.then((value) => DeviceInfo(
            versionCode: value.version.sdkInt ?? 0,
            release: value.version.release ?? '',
          ));
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

class DeviceInfo extends Equatable {
  const DeviceInfo({
    required this.versionCode,
    required this.release,
  });

  final int versionCode;
  final String release;

  @override
  List<Object?> get props => [versionCode, release];
}
