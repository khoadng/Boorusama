import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart' as p;

import '../../io/process_runner.dart';
import '../../project/project.dart';
import '../changelog.dart';
import '../git_release.dart';
import '../play/client.dart';
import '../play/config.dart';
import '../play/status.dart';
import 'plan.dart';

final class ReleasePrepareService {
  const ReleasePrepareService({
    required this.root,
    required this.project,
    required this.git,
    this.onProgress,
  });

  final Directory root;
  final Project project;
  final GitRelease git;
  final void Function(String message)? onProgress;

  Future<ReleasePreparePlan> plan(String versionName) async {
    final currentBuildNumber = int.tryParse(project.pubspec.buildNumber ?? '');
    final googlePlay = await _googlePlayPlan();
    final nextBuildNumber = _nextBuildNumber(
      currentBuildNumber: currentBuildNumber,
      googlePlay: googlePlay,
    );
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
      googlePlay: googlePlay,
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
    if (!plan.googlePlay.serviceAccountJsonConfigured) {
      throw const ProcessFailure(
        'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not configured.',
      );
    }
    if (!plan.googlePlay.serviceAccountJsonExists) {
      throw ProcessFailure(
        'Google Play service account file does not exist: ${plan.googlePlay.serviceAccountJson}.',
      );
    }
    if (!plan.googlePlay.serviceAccountJsonValid) {
      throw const ProcessFailure(
        'Google Play service account JSON is invalid or is not a service account.',
      );
    }
    if (!plan.googlePlay.packageNameConfigured) {
      throw const ProcessFailure('GOOGLE_PLAY_PACKAGE_NAME is not configured.');
    }
    if (!plan.googlePlay.packageNameMatchesAndroid) {
      throw ProcessFailure(
        'GOOGLE_PLAY_PACKAGE_NAME does not match Android applicationId: ${plan.googlePlay.packageName} != ${plan.googlePlay.androidApplicationId}.',
      );
    }
    if (!plan.googlePlay.api.checked) {
      throw const ProcessFailure('Google Play API check did not run.');
    }
    if (!plan.googlePlay.api.succeeded) {
      throw ProcessFailure(
        'Google Play API check failed: ${plan.googlePlay.api.error ?? 'unknown error'}.',
      );
    }
    if (!plan.googlePlay.api.plannedVersionCodeIsNewer(
      _plannedVersionCode(plan),
    )) {
      throw ProcessFailure(
        'Planned versionCode ${_plannedVersionCode(plan)} is not newer than Google Play production ${plan.googlePlay.api.productionMaxVersionCode}.',
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

  Future<GooglePlayPreparePlan> _googlePlayPlan() async {
    final serviceAccountJson = project.env['GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'];
    final serviceAccountJsonFile = serviceAccountJson == null
        ? null
        : File(_resolveRootPath(serviceAccountJson));
    final packageName = project.env['GOOGLE_PLAY_PACKAGE_NAME'];
    final configResolver = PlayReleaseConfigResolver(
      root: root,
      project: project,
    );
    final androidApplicationId = configResolver.androidApplicationId();
    final localPlan = GooglePlayPreparePlan(
      serviceAccountJson: serviceAccountJson,
      serviceAccountJsonExists: serviceAccountJsonFile?.existsSync() ?? false,
      serviceAccountJsonValid: serviceAccountJsonFile == null
          ? false
          : configResolver.isServiceAccountJson(serviceAccountJsonFile),
      packageName: packageName,
      androidApplicationId: androidApplicationId,
      api: const GooglePlayApiPreparePlan.notChecked(),
    );

    if (!localPlan.serviceAccountReady ||
        !localPlan.packageNameMatchesAndroid) {
      return localPlan;
    }

    return GooglePlayPreparePlan(
      serviceAccountJson: serviceAccountJson,
      serviceAccountJsonExists: localPlan.serviceAccountJsonExists,
      serviceAccountJsonValid: localPlan.serviceAccountJsonValid,
      packageName: packageName,
      androidApplicationId: androidApplicationId,
      api: await _googlePlayApiPlan(
        serviceAccountJsonFile: serviceAccountJsonFile!,
        packageName: packageName!,
      ),
    );
  }

  Future<GooglePlayApiPreparePlan> _googlePlayApiPlan({
    required File serviceAccountJsonFile,
    required String packageName,
  }) async {
    try {
      onProgress?.call('Checking Google Play release state.');
      final status = await GooglePlayReleaseRepository(
        serviceAccountJsonFile: serviceAccountJsonFile,
        packageName: packageName,
        onProgress: onProgress,
      ).fetchStatus();
      final latestRelease = _latestProductionRelease(status);

      return GooglePlayApiPreparePlan(
        checked: true,
        succeeded: true,
        error: null,
        productionTrack: status.track,
        productionReleaseCount: status.production.releases.length,
        productionMaxVersionCode: status.productionMaxVersionCode,
        productionLatestReleaseName: latestRelease?.name,
        productionLatestReleaseStatus: latestRelease?.status,
        trackCount: status.tracks.length,
        defaultLanguage: status.defaultLanguage,
        contactEmail: status.contactEmail,
        listingLanguages: status.listingLanguages,
      );
    } on Object catch (error) {
      return GooglePlayApiPreparePlan(
        checked: true,
        succeeded: false,
        error: error.toString(),
        productionTrack: 'production',
        productionReleaseCount: null,
        productionMaxVersionCode: null,
        productionLatestReleaseName: null,
        productionLatestReleaseStatus: null,
        trackCount: null,
        defaultLanguage: null,
        contactEmail: null,
        listingLanguages: const [],
      );
    }
  }

  int? _nextBuildNumber({
    required int? currentBuildNumber,
    required GooglePlayPreparePlan googlePlay,
  }) {
    final localNextBuildNumber = currentBuildNumber == null
        ? null
        : currentBuildNumber + 1;
    final playNextBuildNumber = googlePlay.api.productionMaxVersionCode == null
        ? null
        : googlePlay.api.productionMaxVersionCode! + 1;

    if (localNextBuildNumber == null) return playNextBuildNumber;
    if (playNextBuildNumber == null) return localNextBuildNumber;
    return math.max(localNextBuildNumber, playNextBuildNumber);
  }

  PlayTrackRelease? _latestProductionRelease(PlayReleaseStatus status) {
    PlayTrackRelease? latest;
    var latestCode = -1;
    for (final release in status.production.releases) {
      for (final versionCode in release.versionCodes) {
        if (versionCode > latestCode) {
          latestCode = versionCode;
          latest = release;
        }
      }
    }
    return latest;
  }

  String _resolveRootPath(String value) {
    if (p.isAbsolute(value)) return value;
    return p.join(root.path, value);
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

  int? _plannedVersionCode(ReleasePreparePlan plan) {
    final nextFullVersion = plan.nextFullVersion;
    final separatorIndex = nextFullVersion?.lastIndexOf('+') ?? -1;
    if (nextFullVersion == null || separatorIndex < 0) {
      return null;
    }
    return int.tryParse(nextFullVersion.substring(separatorIndex + 1));
  }
}
