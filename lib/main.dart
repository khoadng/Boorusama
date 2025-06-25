// Project imports:
import 'boot.dart';
import 'core/app_rating/providers.dart';
import 'core/foundation/boot.dart';
import 'core/foundation/iap/iap.dart';
import 'core/foundation/loggers.dart';
import 'core/foundation/platform.dart';
import 'core/foundation/revenuecat/revenuecat.dart';
import 'core/google/google_play_services_impl.dart';

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
