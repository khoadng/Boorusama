import 'build_options.dart';

final class DartDefines {
  const DartDefines._();

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
