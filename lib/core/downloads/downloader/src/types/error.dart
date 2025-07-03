// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:foundation/foundation.dart';

enum FileSystemDownloadErrorType {
  directoryNotFound,
  restrictedDirectory,
  needElevatedPermission,
  readOnlyDirectory,
  failedToCreateFile,
  fileNameTooLong,
}

sealed class DownloadError {
  DownloadError({
    required this.savedPath,
    required this.fileName,
  });

  final Option<String> savedPath;
  final String fileName;
}

final class HttpDownloadError extends DownloadError {
  HttpDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.exception,
  });

  final DioException exception;
}

final class GenericDownloadError extends DownloadError {
  GenericDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.message,
  });

  final String message;
}

final class FileSystemDownloadError extends DownloadError {
  FileSystemDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.error,
  }) {
    if (error is PathNotFoundException) {
      type = FileSystemDownloadErrorType.directoryNotFound;
    } else {
      type = switch (error.osError?.errorCode) {
        1 => FileSystemDownloadErrorType.needElevatedPermission,
        13 => FileSystemDownloadErrorType.restrictedDirectory,
        30 => FileSystemDownloadErrorType.readOnlyDirectory,
        36 => FileSystemDownloadErrorType.fileNameTooLong,
        _ => FileSystemDownloadErrorType.failedToCreateFile,
      };
    }
  }

  late FileSystemDownloadErrorType type;
  final FileSystemException error;
}
