// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';

// Project imports:
import 'toast.dart';

export 'package:file_picker/file_picker.dart' show FileType;

Future<void> pickDirectoryPathToastOnError({
  required BuildContext context,
  required void Function(String path) onPick,
  void Function()? onCanceled,
}) =>
    pickDirectoryPath(
      onPick: onPick,
      onCanceled: onCanceled,
      onError: (e) {
        showErrorToast(
          context,
          e.toString(),
        );
      },
    );

Future<void> pickSingleFilePathToastOnError({
  required BuildContext context,
  required void Function(String path) onPick,
  FileType type = FileType.any,
  List<String>? allowedExtensions,
}) =>
    pickSingleFilePath(
      type: type,
      allowedExtensions: allowedExtensions,
      onPick: onPick,
      onError: (e) {
        showErrorToast(
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
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
    );

    if (result == null) {
      onCanceled?.call();
      return;
    }

    final file = result.files.singleOrNull;

    if (file == null) {
      onError?.call('No file picked');
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
}) async {
  try {
    final path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      onPick(path);
    } else {
      onCanceled?.call();
    }
  } catch (error) {
    onError?.call(error);
  }
}
