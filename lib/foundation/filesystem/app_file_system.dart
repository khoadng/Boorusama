// Dart imports:
import 'dart:async';
import 'dart:typed_data';

abstract interface class AppFileSystem {
  // Path resolution
  Future<String> getAppStoragePath();
  Future<String?> getTemporaryPath();
  Future<String?> getDownloadPath();

  // File operations
  Future<bool> fileExists(String path);
  bool fileExistsSync(String path);

  Future<Uint8List> readBytes(String path);
  Uint8List readBytesSync(String path);

  Future<void> writeBytes(String path, Uint8List bytes);

  Future<String> readString(String path);

  Future<void> writeString(String path, String content);

  Future<void> deleteFile(String path);

  Future<void> copyFile(String source, String destination);
  void copyFileSync(String source, String destination);

  Future<void> renameFile(String source, String destination);

  Future<int> fileSize(String path);
  int fileSizeSync(String path);

  Future<DateTime> lastModified(String path);
  DateTime lastModifiedSync(String path);

  Stream<List<int>> openRead(String path, {int? start, int? end});

  Future<StreamSink<List<int>>> openWrite(String path);

  // Temp directory
  Future<String> createTempDirectory(String prefix);

  // Directory operations
  Future<bool> directoryExists(String path);
  bool directoryExistsSync(String path);

  Future<void> createDirectory(String path, {bool recursive = false});

  Future<void> deleteDirectory(String path, {bool recursive = false});
  void deleteDirectorySync(String path, {bool recursive = false});

  Future<List<FileSystemEntry>> listDirectory(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  });

  List<FileSystemEntry> listDirectorySync(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  });

  Stream<FileSystemEntry> listDirectoryStream(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  });
}

enum FileSystemEntryType {
  file,
  directory,
}

class FileSystemEntry {
  FileSystemEntry({
    required this.path,
    required this.type,
  });

  final String path;
  final FileSystemEntryType type;

  bool get isFile => type == FileSystemEntryType.file;
  bool get isDirectory => type == FileSystemEntryType.directory;
}
