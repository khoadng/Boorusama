import 'package:boorusama/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'platform.dart';

bool isFirebaseCrashlyticsSupportedPlatforms() =>
    isAndroid() || isIOS() || isMacOS();
bool isFirebaseAnalyticsSupportedPlatforms() =>
    isAndroid() || isIOS() || isMacOS() || isWeb();

Future<void> ensureFirebaseInitialized() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
