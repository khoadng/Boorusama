// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../configs/config.dart';
import '../../foundation/path.dart';
import '../../settings/settings.dart';
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

typedef DownloadTaskInfoOrError = TaskEither<DownloadError, DownloadTaskInfo>;

class DownloadTaskInfo extends Equatable {
  const DownloadTaskInfo({
    required this.path,
    required this.id,
  });

  final String path;
  final String id;

  @override
  List<Object?> get props => [path, id];
}

abstract class DownloadService {
  DownloadTaskInfoOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  });

  DownloadTaskInfoOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  });

  Future<bool> cancelTasksWithIds(List<String> ids);

  Future<void> pauseAll(String group);

  Future<void> resumeAll(String group);
}

extension DownloadWithSettingsX on DownloadService {
  DownloadTaskInfoOrError downloadWithSettings(
    Settings settings, {
    required String url,
    required String filename,
    required BooruConfig config,
    required Map<String, String>? headers,
    DownloaderMetadata? metadata,
    String? folderName,
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
