// Project imports:
import 'bulk_download_error_code.dart';

sealed class BulkDownloadError implements Exception {
  const BulkDownloadError(this.code, this.message);
  final BulkDownloadErrorCode code;
  final String message;

  @override
  String toString() => '${code.code}: $message';
}

sealed class BulkDownloadOptionsError implements Exception {
  const BulkDownloadOptionsError(this.message);
  final String message;

  @override
  String toString() => message;
}

class TaskNotFoundError extends BulkDownloadError {
  const TaskNotFoundError()
    : super(BulkDownloadErrorCode.taskNotFound, 'Task not found');
}

class StoragePermissionDeniedError extends BulkDownloadError {
  const StoragePermissionDeniedError()
    : super(
        BulkDownloadErrorCode.storagePermissionDenied,
        'Storage permission is not granted',
      );
}

class StoragePermanentlyDeniedError extends BulkDownloadError {
  const StoragePermanentlyDeniedError()
    : super(
        BulkDownloadErrorCode.storagePermanentlyDenied,
        'Storage permission permanently denied, please enable it in Settings',
      );
}

class NoRunningSessionError extends BulkDownloadError {
  const NoRunningSessionError()
    : super(
        BulkDownloadErrorCode.noRunningSession,
        'No running session found',
      );
}

class NoPostsFoundError extends BulkDownloadError {
  const NoPostsFoundError()
    : super(
        BulkDownloadErrorCode.noPostsFound,
        'No posts found for the specified tags',
      );
}

class SessionNotFoundError extends BulkDownloadError {
  const SessionNotFoundError()
    : super(BulkDownloadErrorCode.sessionNotFound, 'Session not found');
}

class EmptyTagsError extends BulkDownloadError {
  const EmptyTagsError()
    : super(BulkDownloadErrorCode.emptyTags, 'Tags cannot be empty');
}

class RunningSessionDeletionError extends BulkDownloadError {
  const RunningSessionDeletionError()
    : super(
        BulkDownloadErrorCode.runningSessionDeletion,
        'runningSessionDeletionError',
      );
}

class FreeUserMultipleDownloadSessionsError extends BulkDownloadError {
  const FreeUserMultipleDownloadSessionsError()
    : super(
        BulkDownloadErrorCode.nonPremiumSessionLimit,
        'nonPremiumSessionLimitError',
      );
}

class InvalidDownloadOptionsError extends BulkDownloadOptionsError {
  const InvalidDownloadOptionsError()
    : super(
        'Invalid download options',
      );
}

class DownloadRecordNotFoundError extends BulkDownloadError {
  const DownloadRecordNotFoundError()
    : super(
        BulkDownloadErrorCode.downloadRecordNotFound,
        'Download record not found',
      );
}

class SessionNotRunningError extends BulkDownloadError {
  const SessionNotRunningError()
    : super(
        BulkDownloadErrorCode.sessionNotRunning,
        'Session is not running',
      );
}

class UnknownBulkDownloadError extends BulkDownloadError {
  const UnknownBulkDownloadError(String message)
    : super(BulkDownloadErrorCode.unknown, message);
}

class NonPremiumSuspendError extends BulkDownloadError {
  const NonPremiumSuspendError()
    : super(
        BulkDownloadErrorCode.nonPremiumSuspend,
        'nonPremiumSuspendError',
      );
}

class NonPremiumResumeError extends BulkDownloadError {
  const NonPremiumResumeError()
    : super(
        BulkDownloadErrorCode.nonPremiumResume,
        'nonPremiumResumeError',
      );
}

class NonPremiumSavedTaskLimitError extends BulkDownloadError {
  const NonPremiumSavedTaskLimitError()
    : super(
        BulkDownloadErrorCode.nonPremiumSavedTaskLimit,
        'nonPremiumSavedTaskLimitError',
      );
}

class DirectoryNotFoundError extends BulkDownloadError {
  const DirectoryNotFoundError()
    : super(
        BulkDownloadErrorCode.directoryNotFound,
        'Directory does not exist.',
      );
}
