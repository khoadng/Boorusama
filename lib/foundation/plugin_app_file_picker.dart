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
  Future<String?> pickDirectory({String? initialDirectory}) =>
      FilePicker.getDirectoryPath(initialDirectory: initialDirectory);
}
