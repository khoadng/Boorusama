// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../package_info.dart';
import '../platform.dart';
import 'app_update_checker.dart';
import 'play_store_update_checker.dart';

final shouldCheckForUpdateProvider = Provider<bool>((ref) {
  return !ref.watch(isDevEnvironmentProvider) && isAndroid();
});

final appUpdateCheckerProvider = Provider<AppUpdateChecker>(
  (ref) => isAndroid()
      ? PlayStoreUpdateChecker(
          packageInfo: ref.watch(packageInfoProvider),
          countryCode: 'US',
          languageCode: 'en',
        )
      : UnsupportedPlatformChecker(),
);

final appUpdateStatusProvider = FutureProvider<UpdateStatus>((ref) async {
  if (!ref.watch(shouldCheckForUpdateProvider)) {
    return const UpdateNotAvailable();
  }

  final checker = ref.watch(appUpdateCheckerProvider);
  return checker.checkForUpdate();
});
