final class ReleasePreparePlan {
  const ReleasePreparePlan({
    required this.currentVersion,
    required this.versionName,
    required this.nextFullVersion,
    required this.branch,
    required this.tag,
    required this.workingTreeClean,
    required this.localBranchExists,
    required this.remoteBranchExists,
    required this.localTagExists,
    required this.remoteTagExists,
    required this.changelogStatus,
    required this.changes,
  });

  final String currentVersion;
  final String versionName;
  final String? nextFullVersion;
  final String branch;
  final String tag;
  final bool workingTreeClean;
  final bool localBranchExists;
  final bool remoteBranchExists;
  final bool localTagExists;
  final bool remoteTagExists;
  final ChangelogStatus changelogStatus;
  final List<ReleasePrepareChange> changes;
}

final class ReleasePrepareChange {
  const ReleasePrepareChange({
    required this.path,
    required this.before,
    required this.after,
  });

  final String path;
  final String before;
  final String after;
}

enum ChangelogStatus {
  exactVersion,
  prerelease,
  missing,
}

extension ChangelogStatusLabel on ChangelogStatus {
  String get label => switch (this) {
    ChangelogStatus.exactVersion => 'exact version',
    ChangelogStatus.prerelease => 'top prerelease section',
    ChangelogStatus.missing => 'missing',
  };
}
