// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../downloads/path/types.dart';
import 'service.dart';
import 'types.dart';

final autoBackupRepositoryProvider = Provider<AutoBackupRepository>((ref) {
  return const AutoBackupRepositoryIo();
});

class AutoBackupRepositoryIo implements AutoBackupRepository {
  const AutoBackupRepositoryIo();

  @override
  Future<String> getBackupDirectoryPath(String? userSelectedPath) async {
    final downloadsDir = await _getDownloadDirectory();

    final baseDir = userSelectedPath ?? downloadsDir.path;

    final backupDirPath = p.join(baseDir, AutoBackupService.backupFolderName);
    final backupDir = Directory(backupDirPath);
    await backupDir.create(recursive: true);
    return backupDirPath;
  }

  @override
  Future<AutoBackupManifest> loadManifest(String backupDirPath) async {
    final manifestFile = File(
      p.join(backupDirPath, AutoBackupService.manifestFileName),
    );

    if (!manifestFile.existsSync()) {
      return const AutoBackupManifest(backups: []);
    }

    try {
      final content = await manifestFile.readAsString();
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
    final manifestFile = File(
      p.join(backupDirPath, AutoBackupService.manifestFileName),
    );
    await manifestFile.writeAsString(jsonEncode(manifest.toJson()));
  }

  @override
  Future<void> deleteFile(String filePath) async {
    await File(filePath).delete();
  }

  @override
  List<String> listZipFiles(String backupDirPath) {
    return Directory(backupDirPath)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .map((f) => p.basename(f.path))
        .toList();
  }

  @override
  bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  @override
  Future<int> getFileSize(String filePath) {
    return File(filePath).length();
  }
}

Future<Directory> _getDownloadDirectory() async {
  final result = await tryGetDownloadDirectory();

  return switch (result) {
    DownloadDirectorySuccess(:final directory) => directory,
    DownloadDirectoryFailure(:final message) => throw Exception(
      message ?? 'Could not find downloads directory',
    ),
  };
}
