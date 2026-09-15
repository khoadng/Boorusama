import 'dart:io';

import 'build_options.dart';

final class DartDefines {
  const DartDefines._();

  static DateTime buildTimestamp({
    Map<String, String>? environment,
    DateTime Function()? now,
  }) {
    final value = (environment ?? Platform.environment)['SOURCE_DATE_EPOCH'];
    if (value == null || value.isEmpty) return (now ?? DateTime.now)();

    final seconds = int.tryParse(value);
    if (seconds == null || seconds < 0) {
      throw FormatException(
        'SOURCE_DATE_EPOCH must be a non-negative Unix timestamp: $value',
      );
    }
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  static List<String> args(Map<String, String> values) {
    return [
      for (final entry in values.entries)
        '--dart-define=${entry.key}=${entry.value}',
    ];
  }

  static Map<String, String> common({
    required String gitCommit,
    required String gitBranch,
    required bool foss,
    required String releaseChannel,
    required DateTime timestamp,
  }) {
    return {
      'GIT_COMMIT': gitCommit,
      'GIT_BRANCH': gitBranch,
      'BUILD_TIMESTAMP': timestamp.toUtc().toIso8601String(),
      'IS_FOSS_BUILD': foss.toString(),
      'RELEASE_CHANNEL': releaseChannel,
    };
  }

  static Map<String, String> androidFoss(BuildOptions options) {
    if (!options.foss) return const {};
    if (options.target.name != 'apk' && options.target.name != 'aab') {
      return const {};
    }
    return const {'cronetHttpNoPlay': 'true'};
  }
}
