import 'dart:io';

import '../../io/process_runner.dart';
import '../../project/project.dart';
import '../changelog.dart';
import '../git_release.dart';
import 'plan.dart';

final class ReleasePrepareService {
  const ReleasePrepareService({
    required this.root,
    required this.project,
    required this.git,
  });

  final Directory root;
  final Project project;
  final GitRelease git;

  Future<ReleasePreparePlan> plan(String versionName) async {
    final currentBuildNumber = int.tryParse(project.pubspec.buildNumber ?? '');
    final nextBuildNumber = currentBuildNumber == null
        ? null
        : currentBuildNumber + 1;
    final nextFullVersion = nextBuildNumber == null
        ? null
        : '$versionName+$nextBuildNumber';
    final tag = 'v$versionName';
    final changelogFile = File('${root.path}/CHANGELOG.md');
    final changelogStatus = _changelogStatus(changelogFile, versionName);

    return ReleasePreparePlan(
      currentVersion: project.pubspec.version,
      versionName: versionName,
      nextFullVersion: nextFullVersion,
      branch: versionName,
      tag: tag,
      workingTreeClean: await git.isWorkingTreeClean(),
      localBranchExists: await git.localBranchExists(versionName),
      remoteBranchExists: await git.remoteBranchExists(versionName),
      localTagExists: await git.localTagExists(tag),
      remoteTagExists: await git.remoteTagExists(tag),
      changelogStatus: changelogStatus,
      changes: _plannedChanges(
        changelogFile: changelogFile,
        changelogStatus: changelogStatus,
        currentVersion: project.pubspec.version,
        nextFullVersion: nextFullVersion,
        versionName: versionName,
      ),
    );
  }

  void validate(ReleasePreparePlan plan) {
    if (!_isVersionName(plan.versionName)) {
      throw ProcessFailure(
        'Invalid release version: ${plan.versionName}. Expected X.Y.Z.',
      );
    }
    if (plan.nextFullVersion == null) {
      throw ProcessFailure(
        'Current pubspec version does not have a numeric build number: ${plan.currentVersion}.',
      );
    }
    if (!plan.workingTreeClean) {
      throw const ProcessFailure(
        'Working tree is not clean. Commit or stash changes before preparing a release.',
      );
    }
    if (plan.localTagExists || plan.remoteTagExists) {
      throw ProcessFailure(
        'Release tag already exists: ${plan.tag}. Use a new version.',
      );
    }
    if (plan.changelogStatus == ChangelogStatus.missing) {
      throw ProcessFailure(
        'CHANGELOG.md does not contain a # ${plan.versionName} section or a top prerelease section.',
      );
    }
  }

  Future<void> apply(ReleasePreparePlan plan) async {
    if (plan.localBranchExists) {
      await git.checkoutBranch(plan.branch);
    } else if (plan.remoteBranchExists) {
      await git.checkoutRemoteBranch(plan.branch);
    } else {
      await git.createBranch(plan.branch);
    }

    final pubspec = File('${root.path}/pubspec.yaml');
    final lines = pubspec.readAsLinesSync();
    final versionLineIndex = lines.indexWhere(
      (line) => line.startsWith('version:'),
    );
    if (versionLineIndex < 0) {
      throw const ProcessFailure(
        'pubspec.yaml does not contain a version field.',
      );
    }

    lines[versionLineIndex] = 'version: ${plan.nextFullVersion}';
    pubspec.writeAsStringSync('${lines.join('\n')}\n');

    if (plan.changelogStatus == ChangelogStatus.prerelease) {
      final changelog = File('${root.path}/CHANGELOG.md');
      final lines = changelog.readAsLinesSync();
      if (lines.isEmpty) {
        throw const ProcessFailure('CHANGELOG.md is empty.');
      }
      lines[0] = '# ${plan.versionName}';
      changelog.writeAsStringSync('${lines.join('\n')}\n');
    }
  }

  ChangelogStatus _changelogStatus(File changelogFile, String versionName) {
    try {
      Changelog(changelogFile).sectionFor(versionName);
      return ChangelogStatus.exactVersion;
    } on Object {
      final lines = changelogFile.existsSync()
          ? changelogFile.readAsLinesSync()
          : const <String>[];
      final firstLine = lines.isEmpty ? null : lines.first.trim();
      if (firstLine?.toLowerCase().startsWith('# prereleased') ?? false) {
        return ChangelogStatus.prerelease;
      }
      return ChangelogStatus.missing;
    }
  }

  List<ReleasePrepareChange> _plannedChanges({
    required File changelogFile,
    required ChangelogStatus changelogStatus,
    required String currentVersion,
    required String? nextFullVersion,
    required String versionName,
  }) {
    final changes = <ReleasePrepareChange>[];

    if (nextFullVersion != null) {
      changes.add(
        ReleasePrepareChange(
          path: 'pubspec.yaml',
          before: 'version: $currentVersion',
          after: 'version: $nextFullVersion',
        ),
      );
    }

    if (changelogStatus == ChangelogStatus.prerelease) {
      final lines = changelogFile.existsSync()
          ? changelogFile.readAsLinesSync()
          : const <String>[];
      if (lines.isNotEmpty) {
        changes.add(
          ReleasePrepareChange(
            path: 'CHANGELOG.md',
            before: lines.first,
            after: '# $versionName',
          ),
        );
      }
    }

    return changes;
  }

  bool _isVersionName(String value) {
    return RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value);
  }
}
