// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// Project imports:
import 'package:boorusama/foundation/filesystem.dart';

/// An in-memory [AppFileSystem] for tests that must exercise file behavior.
/// No method resolves or touches a host filesystem path.
final class MemoryAppFileSystem implements AppFileSystem {
  final _files = <String, Uint8List>{};
  final _directories = <String>{'/memory'};
  final _modified = <String, DateTime>{};
  var _temporaryDirectoryIndex = 0;

  @override
  Future<String> getAppStoragePath() async => '/memory/app';

  @override
  Future<String?> getTemporaryPath() async => '/memory/tmp';

  @override
  Future<String?> getDownloadPath() async => '/memory/downloads';

  @override
  Future<bool> fileExists(String path) async => fileExistsSync(path);

  @override
  bool fileExistsSync(String path) => _files.containsKey(path);

  @override
  Future<Uint8List> readBytes(String path) async => readBytesSync(path);

  @override
  Uint8List readBytesSync(String path) {
    final bytes = _files[path];
    if (bytes == null) throw StateError('File does not exist: $path');
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> writeBytes(String path, Uint8List bytes) async {
    _ensureParentDirectories(path);
    _files[path] = Uint8List.fromList(bytes);
    _modified[path] = DateTime.utc(2020);
  }

  @override
  Future<String> readString(String path) async =>
      utf8.decode(readBytesSync(path));

  @override
  Future<String?> readStringIfExists(String path) async {
    if (!fileExistsSync(path)) return null;
    return readString(path);
  }

  @override
  Future<void> writeString(
    String path,
    String content, {
    bool flush = false,
  }) => writeBytes(path, Uint8List.fromList(utf8.encode(content)));

  @override
  Future<void> deleteFile(String path) async {
    if (!fileExistsSync(path)) throw StateError('File does not exist: $path');
    _files.remove(path);
    _modified.remove(path);
  }

  @override
  Future<void> deleteFileIfExists(String path) async {
    if (fileExistsSync(path)) await deleteFile(path);
  }

  @override
  Future<void> copyFile(String source, String destination) async {
    await writeBytes(destination, readBytesSync(source));
  }

  @override
  void copyFileSync(String source, String destination) {
    _ensureParentDirectories(destination);
    _files[destination] = readBytesSync(source);
    _modified[destination] = DateTime.utc(2020);
  }

  @override
  Future<void> renameFile(String source, String destination) async {
    copyFileSync(source, destination);
    await deleteFile(source);
  }

  @override
  Future<int> fileSize(String path) async => fileSizeSync(path);

  @override
  int fileSizeSync(String path) => readBytesSync(path).length;

  @override
  Future<DateTime> lastModified(String path) async => lastModifiedSync(path);

  @override
  DateTime lastModifiedSync(String path) {
    if (!fileExistsSync(path)) throw StateError('File does not exist: $path');
    return _modified[path] ?? DateTime.utc(2020);
  }

  @override
  Stream<List<int>> openRead(String path, {int? start, int? end}) async* {
    final bytes = readBytesSync(path);
    yield bytes.sublist(start ?? 0, end ?? bytes.length);
  }

  @override
  Future<StreamSink<List<int>>> openWrite(String path) async {
    _ensureParentDirectories(path);
    // The returned sink owns the controller and closes it when the caller is
    // done writing.
    // ignore: close_sinks
    final controller = StreamController<List<int>>();
    final chunks = <int>[];
    controller.stream.listen(
      chunks.addAll,
      onDone: () {
        _files[path] = Uint8List.fromList(chunks);
        _modified[path] = DateTime.utc(2020);
      },
    );
    return controller.sink;
  }

  @override
  Future<String> createTempDirectory(String prefix) async {
    final path = '/memory/$prefix-${_temporaryDirectoryIndex++}';
    _directories.add(path);
    return path;
  }

  @override
  Future<bool> directoryExists(String path) async => directoryExistsSync(path);

  @override
  bool directoryExistsSync(String path) => _directories.contains(path);

  @override
  Future<void> createDirectory(String path, {bool recursive = false}) async {
    if (recursive) {
      _ensureParentDirectories(path);
    }
    _directories.add(path);
  }

  @override
  Future<void> deleteDirectory(String path, {bool recursive = false}) async {
    deleteDirectorySync(path, recursive: recursive);
  }

  @override
  void deleteDirectorySync(String path, {bool recursive = false}) {
    if (recursive) {
      _directories.removeWhere(
        (value) => value == path || value.startsWith('$path/'),
      );
      _files.removeWhere((key, _) => key.startsWith('$path/'));
    } else {
      _directories.remove(path);
    }
  }

  @override
  Future<List<FileSystemEntry>> listDirectory(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  }) async => listDirectorySync(path, recursive: recursive);

  @override
  List<FileSystemEntry> listDirectorySync(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  }) {
    final prefix = path.endsWith('/') ? path : '$path/';
    final paths = <String>{
      ..._directories.where((value) => value.startsWith(prefix)),
      ..._files.keys.where((value) => value.startsWith(prefix)),
    };
    return paths
        .where(
          (value) => recursive || !value.substring(prefix.length).contains('/'),
        )
        .map(
          (value) => FileSystemEntry(
            path: value,
            type: _files.containsKey(value)
                ? FileSystemEntryType.file
                : FileSystemEntryType.directory,
          ),
        )
        .toList();
  }

  @override
  Stream<FileSystemEntry> listDirectoryStream(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  }) => Stream.fromIterable(listDirectorySync(path, recursive: recursive));

  void _ensureParentDirectories(String path) {
    final parts = path.split('/');
    final current = StringBuffer();
    for (final part in parts.take(parts.length - 1)) {
      if (part.isEmpty) continue;
      current.write('/$part');
      _directories.add(current.toString());
    }
  }
}
