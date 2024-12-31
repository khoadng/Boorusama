abstract class AppUpdateChecker {
  Future<UpdateStatus> checkForUpdate();
}

sealed class UpdateStatus {
  const UpdateStatus();
}

final class UpdateAvailable extends UpdateStatus {
  const UpdateAvailable({
    required this.storeVersion,
    required this.currentVersion,
    required this.releaseNotes,
    required this.storeUrl,
  });

  final String storeVersion;
  final String currentVersion;
  final String releaseNotes;
  final String storeUrl;
}

final class UpdateNotAvailable extends UpdateStatus {
  const UpdateNotAvailable();
}

final class UpdateError extends UpdateStatus {
  const UpdateError(this.error);

  final Object error;
}

// Unsupport platform checker
class UnsupportedPlatformChecker implements AppUpdateChecker {
  @override
  Future<UpdateStatus> checkForUpdate() async {
    return const UpdateNotAvailable();
  }
}
