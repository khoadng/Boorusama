// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';

// Project imports:
import 'plugin_app_file_picker.dart';

abstract interface class AppFilePicker {
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    bool customFileType = false,
  });

  Future<String?> pickDirectory({String? initialDirectory});
}

final appFilePickerProvider = Provider<AppFilePicker>(
  (_) => throw UnimplementedError(
    'appFilePickerProvider must be overridden',
  ),
);

Future<void> pickDirectoryPathToastOnError({
  required BuildContext context,
  required void Function(String path) onPick,
  void Function()? onCanceled,
  String? initialDirectory,
  AppFilePicker? picker,
}) => pickDirectoryPath(
  picker: picker,
  onPick: onPick,
  onCanceled: onCanceled,
  onError: (e) {
    Kurumi.showErrorToast(
      context,
      e.toString(),
    );
  },
  initialDirectory: initialDirectory,
);

Future<void> pickSingleFilePathToastOnError({
  required BuildContext context,
  required void Function(String path) onPick,
  bool customFileType = false,
  List<String>? allowedExtensions,
  AppFilePicker? picker,
}) => pickSingleFilePath(
  picker: picker,
  customFileType: customFileType,
  allowedExtensions: allowedExtensions,
  onPick: onPick,
  onError: (e) {
    Kurumi.showErrorToast(
      context,
      e.toString(),
    );
  },
);

Future<void> pickSingleFilePath({
  required void Function(String path) onPick,
  bool customFileType = false,
  List<String>? allowedExtensions,
  void Function()? onCanceled,
  void Function(Object error)? onError,
  AppFilePicker? picker,
}) async {
  try {
    final path = await (picker ?? const PluginAppFilePicker()).pickFile(
      customFileType: customFileType,
      allowedExtensions: allowedExtensions,
    );

    if (path == null) {
      onCanceled?.call();
      return;
    }

    onPick(path);
  } catch (error) {
    onError?.call(error);
  }
}

Future<void> pickDirectoryPath({
  required void Function(String path) onPick,
  void Function()? onCanceled,
  void Function(Object error)? onError,
  String? initialDirectory,
  AppFilePicker? picker,
}) async {
  try {
    final path = await (picker ?? const PluginAppFilePicker()).pickDirectory(
      initialDirectory: initialDirectory,
    );

    if (path != null) {
      onPick(path);
    } else {
      onCanceled?.call();
    }
  } catch (error) {
    onError?.call(error);
  }
}
