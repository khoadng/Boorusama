// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../info/package_info.dart';
import '../../platform.dart';
import 'types/app_update_checker.dart';
import 'types/update_status.dart';

const _kReleaseChannel = String.fromEnvironment('RELEASE_CHANNEL');
const _kReleaseChannelGithub = 'github';
const _kReleaseChannelPlay = 'play';

final shouldCheckForUpdateProvider = Provider<bool>((ref) {
  if (ref.watch(isDevEnvironmentProvider) || isWeb()) return false;

  return switch (_kReleaseChannel) {
    _kReleaseChannelPlay => isAndroid(),
    _kReleaseChannelGithub => isMobilePlatform() || isDesktopPlatform(),
    _ => false,
  };
});

final appUpdateCheckerProvider = Provider<AppUpdateChecker>(
  (ref) => UnsupportedPlatformChecker(),
);

final appUpdateStatusProvider = FutureProvider<UpdateStatus>((ref) {
  if (!ref.watch(shouldCheckForUpdateProvider)) {
    return const UpdateNotAvailable();
  }

  final checker = ref.watch(appUpdateCheckerProvider);
  return checker.checkForUpdate();
});
