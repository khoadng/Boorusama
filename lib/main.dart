// Project imports:
import 'boot.dart';
import 'foundation/app_rating/src/rate_my_app_service.dart';
import 'foundation/app_update/providers.dart';
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
      data.logger.debugBoot('Check Cronet availability');
      final cronet = CronetImpl(
        gServices: GooglePlayServicesImpl(),
      );
      final cronetAvailable = await cronet.isAvailable();

      return boot(
        data.copyWith(
          cronetAvailable: cronetAvailable,
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
