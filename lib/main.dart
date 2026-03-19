// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'core/boorusama_app.dart';
import 'foundation/app_rating/src/rate_my_app_service.dart';
import 'foundation/app_update/providers.dart';
import 'foundation/app_update/types.dart';
import 'foundation/filesystem.dart';
import 'foundation/iap/iap.dart';
import 'foundation/loggers.dart';
import 'foundation/platform.dart';
import 'foundation/vendors/google/google_play_services_impl.dart';
import 'foundation/vendors/revenuecat/revenuecat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cronetAvailable = await CronetImpl(
    gServices: GooglePlayServicesImpl(),
  ).isAvailable();

  runApp(
    BoorusamaApp(
      fileSystem: const IoFileSystem(),
      cronetAvailable: cronetAvailable,
      appRatingService: const RateMyAppService(),
      iapFunc: () => _initIap(),
      appUpdateChecker: (packageInfo) => isAndroid()
          ? PlayStoreUpdateChecker(
              packageInfo: packageInfo,
              countryCode: 'US',
              languageCode: 'en',
            )
          : UnsupportedPlatformChecker(),
    ),
  );
}

Future<IAP> _initIap() async {
  final logger = await loggerWith(AppLogger(initialLevel: LogLevel.info));

  if (isMobilePlatform()) {
    return (await initRevenuecatIap(logger)) ?? await initDummyIap();
  }

  return initDummyIap();
}
