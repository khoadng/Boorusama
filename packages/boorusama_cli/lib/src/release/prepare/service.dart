import 'dart:io';
import 'package:path/path.dart' as p;

import '../../io/process_runner.dart';
import '../../project/project.dart';
import '../changelog.dart';
import '../git/repository.dart';
import '../github/prepare.dart';
import '../play/client.dart';
import '../play/config.dart';
import '../play/status.dart';
import '../version/prepare_plan.dart';
import '../version/version_name.dart';
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

  Future<ReleasePreparePlan> plan(
    String versionName, {
    String? githubRepo,
    String githubWorkflow = 'github-release.yml',
  }) async {
    final currentBuildNumber = int.tryParse(project.pubspec.buildNumber ?? '');
    final googlePlay = await _googlePlayPlan();
    final tag = 'v$versionName';
    final changelogFile = File('${root.path}/CHANGELOG.md');
    final changelogStatus = _changelogStatus(changelogFile, versionName);
    final versionPlan = const ReleasePrepareVersionPlanner().plan(
      currentVersionName: project.pubspec.versionName,
      currentBuildNumber: currentBuildNumber,
      requestedVersionName: versionName,
      changelogStatus: changelogStatus,
      googlePlayMaxVersionCode: googlePlay.api.maxVersionCode,
    );
    final github = await _githubPlan(
      repo: githubRepo ?? await _githubRepoFromEnvOrGit(),
      workflow: githubWorkflow,
      tag: tag,
    );

    return ReleasePreparePlan(
      currentVersion: project.pubspec.version,
      versionName: versionName,
      nextFullVersion: versionPlan.nextFullVersion,
      branch: versionName,
      tag: tag,
      workingTreeClean: await git.isWorkingTreeClean(),
      localBranchExists: await git.localBranchExists(versionName),
      remoteBranchExists: await git.remoteBranchExists(versionName),
      localTagExists: await git.localTagExists(tag),
      remoteTagExists: await git.remoteTagExists(tag),
      alreadyPrepared: versionPlan.alreadyPrepared,
      changelogStatus: changelogStatus,
      googlePlay: googlePlay,
      github: github,
      changes: _plannedChanges(
        changelogFile: changelogFile,
        changelogStatus: changelogStatus,
        currentVersion: project.pubspec.version,
        nextFullVersion: versionPlan.nextFullVersion,
        versionName: versionName,
      ),
    );
  }

  void validate(ReleasePreparePlan plan) {
    validatePlan(plan);
  }

  static void validatePlan(ReleasePreparePlan plan) {
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
    if (!plan.alreadyPrepared &&
        !plan.googlePlay.api.plannedVersionCodeIsNewer(
          _plannedVersionCode(plan),
        )) {
      throw ProcessFailure(
        'Planned versionCode ${_plannedVersionCode(plan)} is not newer than Google Play max ${plan.googlePlay.api.maxVersionCode}.',
      );
    }
    if (plan.versionNamePolicy == VersionNamePolicy.blocked) {
      throw ProcessFailure(
        'Release version ${plan.versionName} must be newer than Google Play production ${plan.googlePlay.api.productionLatestVersionName}.',
      );
    }
    if (!plan.github.repoConfigured) {
      throw const ProcessFailure(
        'GitHub repository is not configured. Pass --github-repo OWNER/REPO, set GITHUB_RELEASE_REPOSITORY, or configure a GitHub origin remote.',
      );
    }
    if (!plan.github.workflowFileExists) {
      throw ProcessFailure(
        'GitHub release workflow file does not exist: ${plan.github.workflow}.',
      );
    }
    if (!plan.github.ghInstalled) {
      throw const ProcessFailure(
        'GitHub CLI not found. Install gh and authenticate before preparing a release.',
      );
    }
    if (!plan.github.authenticated) {
      throw ProcessFailure(
        'GitHub CLI is not authenticated: ${plan.github.error ?? 'unknown error'}.',
      );
    }
    if (!plan.github.workflowReadable) {
      throw ProcessFailure(
        'GitHub release workflow is not readable: ${plan.github.error ?? plan.github.workflow}.',
      );
    }
    if (!plan.github.releaseLookupSucceeded) {
      throw ProcessFailure(
        'GitHub release lookup failed: ${plan.github.error ?? 'unknown error'}.',
      );
    }
    if (plan.github.releaseExists && !plan.alreadyPrepared) {
      throw ProcessFailure(
        'GitHub release already exists for ${plan.tag}. Use a new version.',
      );
    }
    if ((plan.localTagExists || plan.remoteTagExists) &&
        !plan.alreadyPrepared) {
      throw ProcessFailure(
        'Release tag already exists: ${plan.tag}. Use a new version.',
      );
    }
    if (!plan.workingTreeClean) {
      throw const ProcessFailure(
        'Working tree is not clean. Commit or stash changes before preparing a release.',
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

    onProgress?.call('Committing release preparation.');
    await git.stageFiles(const ['pubspec.yaml', 'CHANGELOG.md']);
    if (!await git.hasStagedChanges()) {
      throw const ProcessFailure('No release preparation changes to commit.');
    }
    await git.commit('build: prepare for ${plan.versionName}');
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

  Future<GithubPreparePlan> _githubPlan({
    required String? repo,
    required String workflow,
    required String tag,
  }) {
    return GithubPrepareChecker(
      root: root,
      processRunner: git.tools.processRunner,
      onProgress: onProgress,
    ).check(repo: repo, workflow: workflow, tag: tag);
  }

  Future<String?> _githubRepoFromEnvOrGit() async {
    final fromEnv =
        project.env['GITHUB_RELEASE_REPOSITORY'] ??
        project.env['GITHUB_REPOSITORY'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

    final origin = await git.tools.gitOutput(['remote', 'get-url', 'origin']);
    if (origin == 'unknown' || origin.isEmpty) return null;
    return _githubRepoFromRemoteUrl(origin);
  }

  String? _githubRepoFromRemoteUrl(String remoteUrl) {
    final normalized = remoteUrl.trim().replaceFirst(RegExp(r'\.git$'), '');
    final https = RegExp(
      r'^https://github\.com/([^/]+/[^/]+)$',
    ).firstMatch(normalized);
    if (https != null) return https.group(1);

    final ssh = RegExp(
      r'^(?:git@github\.com:|ssh://git@github\.com/)([^/]+/[^/]+)$',
    ).firstMatch(normalized);
    return ssh?.group(1);
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
        maxVersionCode: status.maxVersionCode,
        maxVersionCodeTrack: status.maxVersionCodeTrack?.name,
        productionLatestReleaseName: latestRelease?.name,
        productionLatestVersionName: _releaseVersionName(latestRelease?.name),
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
        maxVersionCode: null,
        maxVersionCodeTrack: null,
        productionLatestReleaseName: null,
        productionLatestVersionName: null,
        productionLatestReleaseStatus: null,
        trackCount: null,
        defaultLanguage: null,
        contactEmail: null,
        listingLanguages: const [],
      );
    }
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

    if (nextFullVersion != null && currentVersion != nextFullVersion) {
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

  static bool _isVersionName(String value) {
    return RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value);
  }

  static int? _plannedVersionCode(ReleasePreparePlan plan) {
    final nextFullVersion = plan.nextFullVersion;
    final separatorIndex = nextFullVersion?.lastIndexOf('+') ?? -1;
    if (nextFullVersion == null || separatorIndex < 0) {
      return null;
    }
    return int.tryParse(nextFullVersion.substring(separatorIndex + 1));
  }

  String? _releaseVersionName(String? releaseName) {
    if (releaseName == null || releaseName.isEmpty) return null;
    final match = RegExp(r'\((\d+\.\d+\.\d+)\)').firstMatch(releaseName);
    if (match != null) return match.group(1);
    return VersionName.tryParse(releaseName)?.toString();
  }
}
