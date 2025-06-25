// Project imports:
import 'boot.dart';
import 'core/foundation/boot.dart';
import 'core/foundation/iap/iap.dart';

void main() async {
  await initializeApp(
    bootFunc: (data) async {
      data.bootLogger.l('Booting FOSS version');
      return boot(
        data.copyWith(
          isFossBuild: true,
          iapFunc: () => initDummyIap(),
        ),
      );
    },
  );
}
