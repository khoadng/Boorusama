// Dart imports:
import 'dart:io';

// Package imports:
import 'package:file_picker/file_picker.dart';

// Project imports:
import 'picker.dart';

final class PluginAppFilePicker implements AppFilePicker {
  const PluginAppFilePicker();

  @override
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    bool customFileType = false,
  }) async {
    final file = await FilePicker.pickFile(
      type: customFileType ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );

    return file?.path;
  }

  @override
  Future<String?> pickDirectory({String? initialDirectory}) async {
    final path = await FilePicker.getDirectoryPath(
      initialDirectory: initialDirectory,
    );

    return switch (path) {
      final path? => repairPickedDirectory(
        path,
        exists: (path) => Directory(path).existsSync(),
      ),
      null => null,
    };
  }
}

final _rawDownloadsPath = RegExp(r'^/storage/raw/+(/.+)$');
final _downloadsRootPath = RegExp(r'^(/storage/emulated/\d+)/downloads$');

/// On Android 11+, the picker builds a wrong path for folders chosen from the
/// Downloads shortcut: `raw:<path>` ids gain a `/storage/raw/` prefix and the
/// Downloads root becomes a lowercase `downloads` folder.
String repairPickedDirectory(
  String path, {
  required bool Function(String path) exists,
}) {
  if (_rawDownloadsPath.firstMatch(path)?.group(1) case final realPath?) {
    return realPath;
  }

  if (_downloadsRootPath.firstMatch(path)?.group(1) case final root?) {
    return exists(path) ? path : '$root/Download';
  }

  return path;
}
