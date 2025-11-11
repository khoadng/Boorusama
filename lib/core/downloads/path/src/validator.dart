// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:foundation/foundation.dart';

const _basePath = '/storage/emulated';
const _sdCardBasePath = '/storage';

sealed class PathInfo {
  const PathInfo(this.path);

  factory PathInfo.from(
    String? path, {
    TargetPlatform? platform,
  }) {
    if (path == null || path.isEmpty) return const DefaultPath();

    final targetPlatform = platform ?? defaultTargetPlatform;

    return switch (targetPlatform) {
      TargetPlatform.android => AndroidPathInfo.parse(path),
      TargetPlatform.iOS => IOSPath(path),
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => DesktopPath(path),
      _ => UnsupportedPlatform(path),
    };
  }

  final String path;
}

sealed class AndroidPathInfo extends PathInfo {
  const AndroidPathInfo(super.path);

  static const allowedDownloadFolders = <String>[
    'Download',
    // 'Downloads',
    'Documents',
    'Pictures',
  ];

  static PathInfo parse(String path) {
    return switch (path) {
      final p when p.startsWith(_basePath) => _parseInternalStorage(p),
      final p when p.startsWith(_sdCardBasePath) => _parseSdCardStorage(p),
      _ => AndroidOtherStorage(path),
    };
  }

  String? get publicDirectory;
  bool get isPublicDirectory => publicDirectory != null;

  bool requiresPublicDirectory(int? androidSdkInt) {
    final hasScopeStorage = hasScopedStorage(androidSdkInt) ?? true;
    return hasScopeStorage && !isPublicDirectory;
  }

  static PathInfo _parseInternalStorage(String path) {
    final folders = path.split('/');

    return switch (folders) {
      [_, _, _, final userSpace, ...] when int.tryParse(userSpace) != null =>
        AndroidInternalStorage(
          path: path,
          userSpace: int.parse(userSpace),
          publicDirectory: _extractPublicDirectory(path, _basePath),
        ),
      _ => AndroidOtherStorage(path),
    };
  }

  static PathInfo _parseSdCardStorage(String path) {
    final folders = path.split('/');

    return switch (folders) {
      [_, _, final deviceId, ...] when deviceId != 'emulated' =>
        AndroidSdCardStorage(
          path: path,
          deviceId: deviceId,
          publicDirectory: _extractPublicDirectory(path, _sdCardBasePath),
        ),
      _ => AndroidOtherStorage(path),
    };
  }

  static String? _extractPublicDirectory(String path, String basePath) {
    final paths = path.replaceAll('$basePath/', '').split('/');

    return switch (paths) {
      [_, final folder, ...] when allowedDownloadFolders.contains(folder) =>
        folder,
      _ => null,
    };
  }
}

final class AndroidInternalStorage extends AndroidPathInfo {
  const AndroidInternalStorage({
    required String path,
    required this.userSpace,
    this.publicDirectory,
  }) : super(path);

  final int userSpace;

  @override
  final String? publicDirectory;
}

final class AndroidSdCardStorage extends AndroidPathInfo {
  const AndroidSdCardStorage({
    required String path,
    required this.deviceId,
    this.publicDirectory,
  }) : super(path);

  final String deviceId;

  @override
  final String? publicDirectory;
}

final class AndroidOtherStorage extends AndroidPathInfo {
  const AndroidOtherStorage(super.path);

  @override
  String? get publicDirectory => null;
}

final class IOSPath extends PathInfo {
  const IOSPath(super.path);
}

final class DesktopPath extends PathInfo {
  const DesktopPath(super.path);
}

final class DefaultPath extends PathInfo {
  const DefaultPath() : super('');
}

final class InvalidPath extends PathInfo {
  const InvalidPath(super.path);
}

final class UnsupportedPlatform extends PathInfo {
  const UnsupportedPlatform(super.path);
}
