// Package imports:
import 'package:equatable/equatable.dart';

class BuildInfo extends Equatable {
  const BuildInfo({
    required this.gitCommit,
    required this.gitBranch,
    required this.buildTimestamp,
    required this.isFossBuild,
  });

  static BuildInfo? fromEnvironment({
    required bool isDevBuild,
  }) {
    const gitCommit = String.fromEnvironment(
      'GIT_COMMIT',
      defaultValue: 'unknown',
    );
    const gitBranch = String.fromEnvironment(
      'GIT_BRANCH',
      defaultValue: 'unknown',
    );
    const buildTimestamp = String.fromEnvironment(
      'BUILD_TIMESTAMP',
      defaultValue: 'unknown',
    );
    const isFossBuild = bool.fromEnvironment(
      'IS_FOSS_BUILD',
    );

    if (gitCommit == 'unknown' ||
        gitBranch == 'unknown' ||
        buildTimestamp == 'unknown') {
      return null;
    }

    return const BuildInfo(
      gitCommit: gitCommit,
      gitBranch: gitBranch,
      buildTimestamp: buildTimestamp,
      isFossBuild: isFossBuild,
    );
  }

  final String gitCommit;
  final String gitBranch;
  final String buildTimestamp;
  final bool isFossBuild;

  String shortGitCommit({
    int length = 7,
  }) {
    if (gitCommit.length <= length) {
      return gitCommit;
    }
    return gitCommit.substring(0, length);
  }

  String toInfoString(
    String version, {
    required String Function(DateTime timestamp) formatTimestamp,
  }) {
    final sb = StringBuffer();

    final timestamp = DateTime.tryParse(buildTimestamp);

    final parts = [
      version,
      if (isFossBuild) '(FOSS)',
      '- ${shortGitCommit()}',
      if (timestamp case final t?) '\n${formatTimestamp(t)}',
    ];

    sb.writeAll(parts, ' ');
    return sb.toString();
  }

  @override
  List<Object?> get props => [
    gitCommit,
    gitBranch,
    buildTimestamp,
    isFossBuild,
  ];
}
