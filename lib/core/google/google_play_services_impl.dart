// Package imports:
import 'package:google_api_availability/google_api_availability.dart';

// Project imports:
import 'google_play_services.dart';

class GooglePlayServicesImpl implements GooglePlayServices {
  @override
  Future<bool> isAvailable() async {
    final availability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability();
    return availability == GooglePlayServicesAvailability.success;
  }
}
