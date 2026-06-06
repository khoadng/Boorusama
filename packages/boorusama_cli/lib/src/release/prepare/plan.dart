import '../github/prepare.dart';
import '../version/version_name.dart';

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
    required this.alreadyPrepared,
    required this.changelogStatus,
    required this.googlePlay,
    required this.github,
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
  final bool alreadyPrepared;
  final ChangelogStatus changelogStatus;
  final GooglePlayPreparePlan googlePlay;
  final GithubPreparePlan github;
  final List<ReleasePrepareChange> changes;
}

final class GooglePlayPreparePlan {
  const GooglePlayPreparePlan({
    required this.serviceAccountJson,
    required this.serviceAccountJsonExists,
    required this.serviceAccountJsonValid,
    required this.packageName,
    required this.androidApplicationId,
    required this.api,
  });

  final String? serviceAccountJson;
  final bool serviceAccountJsonExists;
  final bool serviceAccountJsonValid;
  final String? packageName;
  final String? androidApplicationId;
  final GooglePlayApiPreparePlan api;

  bool get serviceAccountJsonConfigured =>
      serviceAccountJson != null && serviceAccountJson!.isNotEmpty;

  bool get serviceAccountReady =>
      serviceAccountJsonConfigured &&
      serviceAccountJsonExists &&
      serviceAccountJsonValid;

  bool get packageNameConfigured =>
      packageName != null && packageName!.isNotEmpty;

  bool get packageNameMatchesAndroid =>
      packageNameConfigured &&
      androidApplicationId != null &&
      packageName == androidApplicationId;
}

final class GooglePlayApiPreparePlan {
  const GooglePlayApiPreparePlan({
    required this.checked,
    required this.succeeded,
    required this.error,
    required this.productionTrack,
    required this.productionReleaseCount,
    required this.productionMaxVersionCode,
    required this.maxVersionCode,
    required this.maxVersionCodeTrack,
    required this.productionLatestReleaseName,
    required this.productionLatestVersionName,
    required this.productionLatestReleaseStatus,
    required this.trackCount,
    required this.defaultLanguage,
    required this.contactEmail,
    required this.listingLanguages,
  });

  const GooglePlayApiPreparePlan.notChecked()
    : checked = false,
      succeeded = false,
      error = null,
      productionTrack = 'production',
      productionReleaseCount = null,
      productionMaxVersionCode = null,
      maxVersionCode = null,
      maxVersionCodeTrack = null,
      productionLatestReleaseName = null,
      productionLatestVersionName = null,
      productionLatestReleaseStatus = null,
      trackCount = null,
      defaultLanguage = null,
      contactEmail = null,
      listingLanguages = const [];

  final bool checked;
  final bool succeeded;
  final String? error;
  final String productionTrack;
  final int? productionReleaseCount;
  final int? productionMaxVersionCode;
  final int? maxVersionCode;
  final String? maxVersionCodeTrack;
  final String? productionLatestReleaseName;
  final String? productionLatestVersionName;
  final String? productionLatestReleaseStatus;
  final int? trackCount;
  final String? defaultLanguage;
  final String? contactEmail;
  final List<String> listingLanguages;

  bool get productionTrackReadable =>
      succeeded && productionReleaseCount != null;

  bool plannedVersionCodeIsNewer(int? plannedVersionCode) {
    final maxVersionCode = this.maxVersionCode;
    return plannedVersionCode != null &&
        (maxVersionCode == null || plannedVersionCode > maxVersionCode);
  }
}

enum VersionNamePolicy {
  unknown,
  ok,
  warnJump,
  blocked,
}

extension ReleasePrepareVersionNamePolicy on ReleasePreparePlan {
  VersionNamePolicy get versionNamePolicy {
    final productionVersion = VersionName.tryParse(
      googlePlay.api.productionLatestVersionName,
    );
    final requestedVersion = VersionName.tryParse(versionName);
    if (productionVersion == null || requestedVersion == null) {
      return VersionNamePolicy.unknown;
    }
    if (requestedVersion.compareTo(productionVersion) <= 0) {
      return VersionNamePolicy.blocked;
    }
    if (requestedVersion.isMoreThanOneStepAfter(productionVersion)) {
      return VersionNamePolicy.warnJump;
    }
    return VersionNamePolicy.ok;
  }
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
