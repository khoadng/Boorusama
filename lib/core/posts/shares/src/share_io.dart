// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cross_file/cross_file.dart';

XFile fileCopySync(String path, String newPath) {
  final file = File(path);
  final newFile = file.copySync(newPath);
  return XFile(newFile.path);
}
