import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class FileManager {
  bool fileExists(String filePath) {
    try {
      return File(filePath).existsSync();
    } catch (e) {
      return false;
    }
  }

  File? getFileIfExists(String filePath) {
    try {
      final file = File(filePath);
      return file.existsSync() ? file : null;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> readFileBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      return await file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  Future<void> writeFileBytes(String filePath, Uint8List bytes) async {
    try {
      final file = File(filePath);
      await file.writeAsBytes(bytes);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<File>> listFiles(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final files = dir.listSync();
      return files.whereType<File>().toList();
    } catch (e) {
      return [];
    }
  }

  int getFileSize(String filePath) {
    try {
      final file = File(filePath);
      return file.existsSync() ? file.lengthSync() : 0;
    } catch (e) {
      return 0;
    }
  }

  FileStat? getFileStats(String filePath) {
    try {
      final file = File(filePath);
      return file.existsSync() ? file.statSync() : null;
    } catch (e) {
      return null;
    }
  }
}
