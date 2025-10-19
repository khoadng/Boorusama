// Project imports:
import 'update_status.dart';

abstract class AppUpdateChecker {
  Future<UpdateStatus> checkForUpdate();
}

// Unsupport platform checker
class UnsupportedPlatformChecker implements AppUpdateChecker {
  @override
  Future<UpdateStatus> checkForUpdate() async {
    return const UpdateNotAvailable();
  }
}
