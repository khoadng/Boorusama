import 'package:boorusama_cli/src/release/github/prepare.dart';
import 'package:boorusama_cli/src/release/prepare/plan.dart';

ReleasePreparePlan preparePlan({
  String currentVersion = '1.2.2+10',
  String versionName = '1.2.3',
  String nextFullVersion = '1.2.3+11',
  String branch = '1.2.3',
  String tag = 'v1.2.3',
  bool workingTreeClean = true,
  bool localBranchExists = false,
  bool remoteBranchExists = false,
  bool localTagExists = false,
  bool remoteTagExists = false,
  bool alreadyPrepared = false,
  ChangelogStatus changelogStatus = ChangelogStatus.exactVersion,
  GooglePlayPreparePlan? googlePlay,
  GithubPreparePlan? github,
}) {
  return ReleasePreparePlan(
    currentVersion: currentVersion,
    versionName: versionName,
    nextFullVersion: nextFullVersion,
    branch: branch,
    tag: tag,
    workingTreeClean: workingTreeClean,
    localBranchExists: localBranchExists,
    remoteBranchExists: remoteBranchExists,
    localTagExists: localTagExists,
    remoteTagExists: remoteTagExists,
    alreadyPrepared: alreadyPrepared,
    changelogStatus: changelogStatus,
    googlePlay: googlePlay ?? googlePlayPreparePlan(),
    github: github ?? githubPreparePlan(),
    changes: const [],
  );
}

GooglePlayPreparePlan googlePlayPreparePlan({
  String? productionVersionName,
  int productionMaxVersionCode = 178,
  int maxVersionCode = 179,
  String maxVersionCodeTrack = 'internal',
}) {
  return GooglePlayPreparePlan(
    serviceAccountJson: '.secret/play.json',
    serviceAccountJsonExists: true,
    serviceAccountJsonValid: true,
    packageName: 'com.degenk.boorusama',
    androidApplicationId: 'com.degenk.boorusama',
    api: GooglePlayApiPreparePlan(
      checked: true,
      succeeded: true,
      error: null,
      productionTrack: 'production',
      productionReleaseCount: 1,
      productionMaxVersionCode: productionMaxVersionCode,
      maxVersionCode: maxVersionCode,
      maxVersionCodeTrack: maxVersionCodeTrack,
      productionLatestReleaseName: productionVersionName == null
          ? null
          : '$productionMaxVersionCode ($productionVersionName)',
      productionLatestVersionName: productionVersionName,
      productionLatestReleaseStatus: 'completed',
      trackCount: 2,
      defaultLanguage: 'en-US',
      contactEmail: null,
      listingLanguages: const ['en-US'],
    ),
  );
}

GithubPreparePlan githubPreparePlan({
  String repo = 'owner/repo',
  String workflow = 'github-release.yml',
  bool releaseExists = false,
}) {
  return GithubPreparePlan(
    repo: repo,
    workflow: workflow,
    workflowFileExists: true,
    ghInstalled: true,
    authenticated: true,
    workflowReadable: true,
    releaseLookupSucceeded: true,
    releaseExists: releaseExists,
    error: null,
  );
}
