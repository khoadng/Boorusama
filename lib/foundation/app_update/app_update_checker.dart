// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/platform.dart';
import 'play_store_update_checker.dart';

abstract class AppUpdateChecker {
  Future<UpdateStatus> checkForUpdate();
}

final shouldCheckForUpdateProvider = Provider<bool>((ref) {
  return isAndroid();
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

sealed class UpdateStatus {
  const UpdateStatus();
}

final class UpdateAvailable extends UpdateStatus {
  const UpdateAvailable({
    required this.storeVersion,
    required this.currentVersion,
    required this.releaseNotes,
    required this.storeUrl,
  });

  final String storeVersion;
  final String currentVersion;
  final String releaseNotes;
  final String storeUrl;
}

final class UpdateNotAvailable extends UpdateStatus {
  const UpdateNotAvailable();
}

final class UpdateError extends UpdateStatus {
  const UpdateError(this.error);

  final Object error;
}

// Unsupport platform checker
class UnsupportedPlatformChecker implements AppUpdateChecker {
  @override
  Future<UpdateStatus> checkForUpdate() async {
    return const UpdateNotAvailable();
  }
}
