// Package imports:
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

    return true;
  }
}
