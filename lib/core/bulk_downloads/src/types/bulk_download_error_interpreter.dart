// Project imports:
import 'bulk_download_error.dart';
import 'bulk_download_error_code.dart';

class BulkDownloadErrorInterpreter {
  static const _errorCodePattern = r'^BD\d{4}:';

  /// Interprets an error string that could be either:
  /// - Legacy format: just the message
  /// - New format: "BD0001: message"
  static (BulkDownloadErrorCode?, String) interpretError(String error) {
    final hasErrorCode = RegExp(_errorCodePattern).hasMatch(error);

    if (!hasErrorCode) {
      return (null, error);
    }

    final code = error.substring(0, 6);
    final message = error.substring(8);
    final errorCode = BulkDownloadErrorCode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => BulkDownloadErrorCode.unknown,
    );

    return (errorCode, message);
  }

  static String serializeError(BulkDownloadError error) {
    return '${error.code.code}: ${error.message}';
  }

  static BulkDownloadError fromString(String error) {
    final (code, message) = interpretError(error);

    if (code == null) {
      return UnknownBulkDownloadError(message);
    }

    return switch (code) {
      BulkDownloadErrorCode.taskNotFound => const TaskNotFoundError(),
      BulkDownloadErrorCode.storagePermissionDenied =>
        const StoragePermissionDeniedError(),
      BulkDownloadErrorCode.storagePermanentlyDenied =>
        const StoragePermanentlyDeniedError(),
      BulkDownloadErrorCode.noRunningSession => const NoRunningSessionError(),
      BulkDownloadErrorCode.noPostsFound => const NoPostsFoundError(),
      BulkDownloadErrorCode.sessionNotFound => const SessionNotFoundError(),
      BulkDownloadErrorCode.emptyTags => const EmptyTagsError(),
      BulkDownloadErrorCode.runningSessionDeletion =>
        const RunningSessionDeletionError(),
      BulkDownloadErrorCode.downloadRecordNotFound =>
        const DownloadRecordNotFoundError(),
      BulkDownloadErrorCode.sessionNotRunning => const SessionNotRunningError(),
      BulkDownloadErrorCode.unknown => UnknownBulkDownloadError(message),
      BulkDownloadErrorCode.nonPremiumSessionLimit =>
        const FreeUserMultipleDownloadSessionsError(),
      BulkDownloadErrorCode.nonPremiumSuspend => const NonPremiumSuspendError(),
      BulkDownloadErrorCode.nonPremiumResume => const NonPremiumResumeError(),
      BulkDownloadErrorCode.nonPremiumSavedTaskLimit =>
        const NonPremiumSavedTaskLimitError(),
      BulkDownloadErrorCode.directoryNotFound => const DirectoryNotFoundError(),
    };
  }
}
