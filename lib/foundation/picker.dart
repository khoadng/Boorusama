// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

export 'package:file_picker/file_picker.dart' show FileType;

Future<void> pickDirectoryPathToastOnError({
  required BuildContext context,
  required void Function(String path) onPick,
  void Function()? onCanceled,
  String? initialDirectory,
}) => pickDirectoryPath(
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
  FileType type = FileType.any,
  List<String>? allowedExtensions,
}) => pickSingleFilePath(
  type: type,
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
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  void Function()? onCanceled,
  void Function(Object error)? onError,
}) async {
  try {
    final file = await FilePicker.pickFile(
      type: type,
      allowedExtensions: allowedExtensions,
    );

    if (file == null) {
      onCanceled?.call();
      return;
    }

    final path = file.path;

    if (path != null) {
      onPick(path);
    } else {
      onError?.call('File path is null');
    }
  } catch (error) {
    onError?.call(error);
  }
}

Future<void> pickDirectoryPath({
  required void Function(String path) onPick,
  void Function()? onCanceled,
  void Function(Object error)? onError,
  String? initialDirectory,
}) async {
  try {
    final path = await FilePicker.getDirectoryPath(
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
