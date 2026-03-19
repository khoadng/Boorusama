// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../../foundation/filesystem.dart';
import '../../downloads/path/types.dart';
import 'service.dart';
import 'types.dart';

final autoBackupRepositoryProvider = Provider<AutoBackupRepository>((ref) {
  return AutoBackupRepositoryIo(
    ref.watch(appFileSystemProvider),
  );
});

class AutoBackupRepositoryIo implements AutoBackupRepository {
  const AutoBackupRepositoryIo(this._fs);

  final AppFileSystem _fs;

  @override
  Future<String> getBackupDirectoryPath(String? userSelectedPath) async {
    final downloadsPath = await _getDownloadDirectoryPath(_fs);

    final baseDir = userSelectedPath ?? downloadsPath;

    final backupDirPath = p.join(baseDir, AutoBackupService.backupFolderName);
    await _fs.createDirectory(backupDirPath, recursive: true);
    return backupDirPath;
  }

  @override
  Future<AutoBackupManifest> loadManifest(String backupDirPath) async {
    final manifestPath = p.join(
      backupDirPath,
      AutoBackupService.manifestFileName,
    );

    if (!_fs.fileExistsSync(manifestPath)) {
      return const AutoBackupManifest(backups: []);
    }

    try {
      final content = await _fs.readString(manifestPath);
      final json = jsonDecode(content) as Map<String, dynamic>;
      return AutoBackupManifest.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveManifest(
    String backupDirPath,
    AutoBackupManifest manifest,
  ) async {
    final manifestPath = p.join(
      backupDirPath,
      AutoBackupService.manifestFileName,
    );
    await _fs.writeString(manifestPath, jsonEncode(manifest.toJson()));
  }

  @override
  Future<void> deleteFile(String filePath) async {
    await _fs.deleteFile(filePath);
  }

  @override
  List<String> listZipFiles(String backupDirPath) {
    return _fs
        .listDirectorySync(backupDirPath)
        .where((e) => e.isFile && e.path.endsWith('.zip'))
        .map((e) => p.basename(e.path))
        .toList();
  }

  @override
  bool fileExists(String filePath) {
    return _fs.fileExistsSync(filePath);
  }

  @override
  Future<int> getFileSize(String filePath) {
    return _fs.fileSize(filePath);
  }
}

Future<String> _getDownloadDirectoryPath(AppFileSystem fs) async {
  final result = await tryGetDownloadDirectory(fs);

  return switch (result) {
    DownloadDirectorySuccess(:final path) => path,
    DownloadDirectoryFailure(:final message) => throw Exception(
      message ?? 'Could not find downloads directory',
    ),
  };
}
