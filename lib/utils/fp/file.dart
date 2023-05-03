// Dart imports:
import 'dart:io';

// Project imports:
import 'package:boorusama/functional.dart';

enum DirectoryError {
  directoryNotFound,
  permissionDenied,
  unknownError,
}

TaskEither<DirectoryError, Directory> tryGetDirectory(String path) =>
    TaskEither.tryCatch(
      () async => Directory(path),
      (error, stackTrace) {
        if (error is FileSystemException) {
          // Permission denied error code
          if (error.osError != null && error.osError!.errorCode == 13) {
            return DirectoryError.permissionDenied;
          } else {
            return DirectoryError.directoryNotFound;
          }
        } else {
          return DirectoryError.unknownError;
        }
      },
    );
