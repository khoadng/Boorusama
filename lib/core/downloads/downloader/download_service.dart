// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/foundation/path.dart';
import 'metadata.dart';

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

typedef DownloadPathOrError = TaskEither<DownloadError, String>;

abstract class DownloadService {
  DownloadPathOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  });

  DownloadPathOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  });
}

extension DownloadWithSettingsX on DownloadService {
  DownloadPathOrError downloadWithSettings(
    Settings settings, {
    required String url,
    DownloaderMetadata? metadata,
    String? folderName,
    required String filename,
    required BooruConfig config,
    required Map<String, String>? headers,
    String? path,
  }) {
    final downloadPath = path ??
        (config.hasCustomDownloadLocation
            ? config.customDownloadLocation
            : settings.downloadPath);

    return downloadPath != null && downloadPath.isNotEmpty
        ? downloadCustomLocation(
            url: url,
            metadata: metadata,
            path: join(downloadPath, folderName),
            filename: filename,
            skipIfExists: settings.skipDownloadIfExists,
            headers: headers,
          )
        : download(
            url: url,
            metadata: metadata,
            filename: filename,
            skipIfExists: settings.skipDownloadIfExists,
            headers: headers,
          );
  }
}

String removeFileExtension(String url) {
  final lastDotIndex = url.lastIndexOf('.');
  if (lastDotIndex != -1) {
    return url.substring(0, lastDotIndex);
  } else {
    // If there is no '.', return the original URL
    return url;
  }
}

extension BooruConfigDownloadX on BooruConfig {
  bool get hasCustomDownloadLocation =>
      customDownloadLocation != null && customDownloadLocation!.isNotEmpty;
}
