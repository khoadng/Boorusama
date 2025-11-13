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

  String getErrorMessage();
}

final class HttpDownloadError extends DownloadError {
  HttpDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.exception,
  });

  final DioException exception;

  @override
  String getErrorMessage() {
    return exception.message ?? 'An unknown HTTP error occurred.';
  }
}

final class GenericDownloadError extends DownloadError {
  GenericDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.message,
  });

  final String message;

  @override
  String getErrorMessage() {
    return message;
  }
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

  @override
  String getErrorMessage() {
    return switch (type) {
      FileSystemDownloadErrorType.directoryNotFound =>
        'The specified directory was not found.',
      FileSystemDownloadErrorType.restrictedDirectory =>
        'The specified directory is restricted and cannot be accessed.',
      FileSystemDownloadErrorType.needElevatedPermission =>
        'Elevated permissions are required to access the specified directory.',
      FileSystemDownloadErrorType.readOnlyDirectory =>
        'The specified directory is read-only and cannot be written to.',
      FileSystemDownloadErrorType.failedToCreateFile =>
        'Failed to create the file in the specified directory.',
      FileSystemDownloadErrorType.fileNameTooLong =>
        'The specified file name is too long for the file system.',
    };
  }
}
