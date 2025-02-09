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
          'Storage permission not granted',
        );
}

class StoragePermanentlyDeniedError extends BulkDownloadError {
  const StoragePermanentlyDeniedError()
      : super(
          BulkDownloadErrorCode.storagePermanentlyDenied,
          'Storage permission permanently denied, please enable it in settings',
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
      : super(BulkDownloadErrorCode.noPostsFound, 'No posts found for tags');
}

class SessionNotFoundError extends BulkDownloadError {
  const SessionNotFoundError()
      : super(BulkDownloadErrorCode.sessionNotFound, 'Session not found');
}

class EmptyTagsError extends BulkDownloadError {
  const EmptyTagsError()
      : super(BulkDownloadErrorCode.emptyTags, 'Tags cannot be empty');
}

class TaskHasActiveSessionsError extends BulkDownloadError {
  const TaskHasActiveSessionsError()
      : super(
          BulkDownloadErrorCode.taskHasActiveSessions,
          'Task has active sessions and cannot be deleted',
        );
}

class FreeUserMultipleDownloadSessionsError extends BulkDownloadOptionsError {
  const FreeUserMultipleDownloadSessionsError()
      : super(
          'Free users can only have one active download session, '
          'please wait until all download sessions are completed.',
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

class IncompleteDownloadsError extends BulkDownloadError {
  const IncompleteDownloadsError()
      : super(
          BulkDownloadErrorCode.incompleteDownloads,
          'Session has incomplete downloads',
        );
}

class SessionNotRunningError extends BulkDownloadError {
  const SessionNotRunningError()
      : super(
          BulkDownloadErrorCode.sessionNotRunning,
          'Session is not running',
        );
}

class DatabaseOperationError extends BulkDownloadError {
  const DatabaseOperationError()
      : super(
          BulkDownloadErrorCode.databaseOperation,
          'Database operation failed',
        );
}

class UnknownBulkDownloadError extends BulkDownloadError {
  const UnknownBulkDownloadError(String message)
      : super(BulkDownloadErrorCode.unknown, message);
}

class NonPremiumResumeError extends BulkDownloadError {
  const NonPremiumResumeError()
      : super(
          BulkDownloadErrorCode.nonPremiumResume,
          'Premium subscription required to resume downloads',
        );
}

class InvalidSessionStatusForResumeError extends BulkDownloadError {
  const InvalidSessionStatusForResumeError()
      : super(
          BulkDownloadErrorCode.invalidSessionStatusForResume,
          'Only failed or cancelled sessions can be resumed',
        );
}
