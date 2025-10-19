// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../info/package_info.dart';
import '../../platform.dart';
import 'types/app_update_checker.dart';
import 'types/update_status.dart';

final shouldCheckForUpdateProvider = Provider<bool>((ref) {
  return !ref.watch(isDevEnvironmentProvider) && isAndroid();
});

final appUpdateCheckerProvider = Provider<AppUpdateChecker>(
  (ref) => throw UnimplementedError(),
);

final appUpdateStatusProvider = FutureProvider<UpdateStatus>((ref) {
  if (!ref.watch(shouldCheckForUpdateProvider)) {
    return const UpdateNotAvailable();
  }

  final checker = ref.watch(appUpdateCheckerProvider);
  return checker.checkForUpdate();
});
