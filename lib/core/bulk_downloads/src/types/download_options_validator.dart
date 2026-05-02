// Project imports:
import '../../../../foundation/info/device_info.dart';
import 'download_configs.dart';
import 'download_options.dart';

bool validDownloadOptions({
  required DownloadOptions options,
  required DeviceInfo deviceInfo,
  DownloadConfigs? downloadConfigs,
}) {
  final androidSdkVersion =
      downloadConfigs?.androidSdkVersion ??
      deviceInfo.androidDeviceInfo?.version.sdkInt;

  return options.valid(androidSdkInt: androidSdkVersion);
}
