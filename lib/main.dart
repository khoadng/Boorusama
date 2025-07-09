// Project imports:
import 'boot.dart';
import 'foundation/app_rating/providers.dart';
import 'foundation/app_update/src/play_store_update_checker.dart';
import 'foundation/app_update/types.dart';
import 'foundation/boot.dart';
import 'foundation/iap/iap.dart';
import 'foundation/loggers.dart';
import 'foundation/platform.dart';
import 'foundation/vendors/google/google_play_services_impl.dart';
import 'foundation/vendors/revenuecat/revenuecat.dart';

void main() async {
  await initializeApp(
    bootFunc: (data) async {
      data.bootLogger.l('Check Google Play Services availability');
      final gServices = GooglePlayServicesImpl();
      final googleApiAvailable = await gServices.isAvailable();

      return boot(
        data.copyWith(
          googleApiAvailable: googleApiAvailable,
          appRatingService: const RateMyAppService(),
          iapFunc: () => initIap(data.logger),
          appUpdateChecker: (packageInfo) => isAndroid()
              ? PlayStoreUpdateChecker(
                  packageInfo: packageInfo,
                  countryCode: 'US',
                  languageCode: 'en',
                )
              : UnsupportedPlatformChecker(),
        ),
      );
    },
  );
}

Future<IAP> initIap(Logger logger) async {
  final IAP iap;

  if (isMobilePlatform()) {
    iap = (await initRevenuecatIap(logger)) ?? await initDummyIap();
  } else {
    iap = await initDummyIap();
  }

  return iap;
}
