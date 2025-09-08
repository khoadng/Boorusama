// Project imports:
import 'boot.dart';
import 'foundation/boot.dart';
import 'foundation/iap/iap.dart';
import 'foundation/loggers.dart';

void main() async {
  await initializeApp(
    bootFunc: (data) {
      data.logger.debugBoot('Booting FOSS version');
      return boot(
        data.copyWith(
          isFossBuild: true,
          iapFunc: () => initDummyIap(),
        ),
      );
    },
  );
}
