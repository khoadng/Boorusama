// Package imports:
import 'package:kurumi/material.dart';

// Project imports:
import 'core/bootstrap/production_boorusama_bootstrap.dart';
import 'core/bootstrap/bootstrap_host.dart';
import 'foundation/app_rating/src/rate_my_app_service.dart';
import 'foundation/app_update/providers.dart';
import 'foundation/filesystem.dart';
import 'foundation/iap/iap.dart';
import 'core/debug/data.dart';
import 'foundation/platform.dart';
import 'foundation/vendors/google/google_play_services_impl.dart';
import 'foundation/vendors/revenuecat/revenuecat.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const BoorusamaBootstrapHost(
      bootstrap: ProductionBoorusamaBootstrap(
        fileSystem: IoFileSystem(),
        appRatingService: RateMyAppService(),
        iapFactory: _initIap,
        appUpdateChecker: createDefaultAppUpdateChecker,
        cronetAvailabilityLoader: _loadCronetAvailability,
      ),
    ),
  );
}

Future<bool> _loadCronetAvailability() {
  return CronetImpl(
    gServices: GooglePlayServicesImpl(),
  ).isAvailable();
}

Future<IAP> _initIap() async {
  final logger = createAppLogger();

  if (isMobilePlatform()) {
    return (await initRevenuecatIap(logger)) ?? await initDummyIap();
  }

  return initDummyIap();
}
