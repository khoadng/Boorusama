import '../prepare/plan.dart';

final class ReleasePrepareVersionPlan {
  const ReleasePrepareVersionPlan({
    required this.alreadyPrepared,
    required this.nextBuildNumber,
    required this.nextFullVersion,
  });

  final bool alreadyPrepared;
  final int? nextBuildNumber;
  final String? nextFullVersion;
}

final class ReleasePrepareVersionPlanner {
  const ReleasePrepareVersionPlanner();

  ReleasePrepareVersionPlan plan({
    required String currentVersionName,
    required int? currentBuildNumber,
    required String requestedVersionName,
    required ChangelogStatus changelogStatus,
    required int? googlePlayMaxVersionCode,
  }) {
    final alreadyPrepared =
        currentVersionName == requestedVersionName &&
        currentBuildNumber != null &&
        changelogStatus == ChangelogStatus.exactVersion;
    final nextBuildNumber = alreadyPrepared
        ? currentBuildNumber
        : _nextBuildNumber(
            currentBuildNumber: currentBuildNumber,
            googlePlayMaxVersionCode: googlePlayMaxVersionCode,
          );

    return ReleasePrepareVersionPlan(
      alreadyPrepared: alreadyPrepared,
      nextBuildNumber: nextBuildNumber,
      nextFullVersion: nextBuildNumber == null
          ? null
          : '$requestedVersionName+$nextBuildNumber',
    );
  }

  int? _nextBuildNumber({
    required int? currentBuildNumber,
    required int? googlePlayMaxVersionCode,
  }) {
    final localNextBuildNumber = currentBuildNumber == null
        ? null
        : currentBuildNumber + 1;
    final playNextBuildNumber = googlePlayMaxVersionCode == null
        ? null
        : googlePlayMaxVersionCode + 1;

    if (localNextBuildNumber == null) return playNextBuildNumber;
    if (playNextBuildNumber == null) return localNextBuildNumber;
    return localNextBuildNumber > playNextBuildNumber
        ? localNextBuildNumber
        : playNextBuildNumber;
  }
}
