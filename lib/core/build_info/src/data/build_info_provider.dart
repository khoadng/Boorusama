// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/info/package_info.dart';
import '../types/build_info.dart';

final buildInfoProvider = Provider<BuildInfo?>(
  (ref) => kDebugMode || kProfileMode
      ? ref.watch(dummyBuildInfoProvider)
      : BuildInfo.fromEnvironment(
          isDevBuild: ref.watch(isDevEnvironmentProvider),
        ),
  name: 'buildInfoProvider',
);

final dummyBuildInfoProvider = Provider<BuildInfo>(
  (ref) => BuildInfo(
    gitCommit: '123456789abcdef0123456789abcdef01234567',
    gitBranch: 'master',
    buildTimestamp: _generateRandomDateFromRange(
      DateTime.now().subtract(const Duration(days: 180)),
      DateTime.now(),
    ).toIso8601String(),
    isFossBuild: false,
  ),
  name: 'dummyBuildInfoProvider',
);

DateTime _generateRandomDateFromRange(DateTime start, DateTime end) {
  final random = DateTime.now().millisecondsSinceEpoch;
  final minMillis = start.millisecondsSinceEpoch;
  final maxMillis = end.millisecondsSinceEpoch;
  final randomMillis = minMillis + (random % (maxMillis - minMillis));

  return DateTime.fromMillisecondsSinceEpoch(randomMillis);
}
