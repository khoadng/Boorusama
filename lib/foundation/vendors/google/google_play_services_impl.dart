// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_api_availability/google_api_availability.dart';

// Project imports:
import '../../platform.dart';
import 'google_play_services.dart';

class GooglePlayServicesImpl implements GooglePlayServices {
  @override
  Future<bool> isAvailable() async {
    if (!isAndroid()) return false;

    final availability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability();
    return availability == GooglePlayServicesAvailability.success;
  }
}

class CronetImpl implements Cronet {
  const CronetImpl({
    required this.gServices,
  });

  final GooglePlayServices gServices;

  @override
  Future<bool> isAvailable() async {
    if (!isAndroid()) return false;

    final gServicesAvailable = await gServices.isAvailable();
    if (!gServicesAvailable) return false;

    // Even if Google Play Services is available, Cronet native libraries
    // are often missing or incompatible on emulators
    return !await _isEmulator();
  }

  Future<bool> _isEmulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return !androidInfo.isPhysicalDevice;
    } catch (e) {
      return false;
    }
  }
}
