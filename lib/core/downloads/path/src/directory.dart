// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';

sealed class DownloadDirectoryResult {
  const DownloadDirectoryResult();
}

final class DownloadDirectorySuccess extends DownloadDirectoryResult {
  const DownloadDirectorySuccess(this.directory);

  final Directory directory;
}

final class DownloadDirectoryFailure extends DownloadDirectoryResult {
  const DownloadDirectoryFailure([this.message]);

  final String? message;
}

Future<DownloadDirectoryResult> tryGetDownloadDirectory() async {
  if (kIsWeb) {
    return const DownloadDirectoryFailure('Web platform not supported');
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => await _tryGetAndroidDownloadDirectory(),
    TargetPlatform.iOS => await _tryGetIosDownloadDirectory(),
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS => await _tryGetDownloadsDirectory(),
    TargetPlatform.fuchsia => const DownloadDirectoryFailure(
      'Platform not supported',
    ),
  };
}

Future<DownloadDirectoryResult> tryGetCustomDownloadDirectory(
  String path,
) async {
  if (kIsWeb) {
    return const DownloadDirectoryFailure('Web platform not supported');
  }

  try {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      return const DownloadDirectoryFailure('Directory not found');
    }
    return DownloadDirectorySuccess(directory);
  } on FileSystemException catch (_) {
    return const DownloadDirectoryFailure('Permission denied');
  } catch (e) {
    return DownloadDirectoryFailure(e.toString());
  }
}

Future<DownloadDirectoryResult> _tryGetAndroidDownloadDirectory() async {
  try {
    final directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      return const DownloadDirectoryFailure('Directory not found');
    }
    return DownloadDirectorySuccess(directory);
  } on FileSystemException catch (_) {
    return const DownloadDirectoryFailure('Permission denied');
  } catch (e) {
    return DownloadDirectoryFailure(e.toString());
  }
}

Future<DownloadDirectoryResult> _tryGetIosDownloadDirectory() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    return DownloadDirectorySuccess(directory);
  } catch (e) {
    return DownloadDirectoryFailure(e.toString());
  }
}

Future<DownloadDirectoryResult> _tryGetDownloadsDirectory() async {
  try {
    final directory = await getDownloadsDirectory();
    return switch (directory) {
      null => const DownloadDirectoryFailure('Directory not found'),
      _ => DownloadDirectorySuccess(directory),
    };
  } catch (e) {
    return DownloadDirectoryFailure(e.toString());
  }
}
