// Project imports:
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infrastructure/device_info_service.dart';

bool hasScopedStorage(DeviceInfo deviceInfo) =>
    isAndroid() && deviceInfo.versionCode >= 29;
