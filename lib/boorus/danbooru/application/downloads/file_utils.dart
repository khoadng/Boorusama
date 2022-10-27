// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path/path.dart';

List<String> getAllFileWithoutExtension(Directory dir) => dir
    .listSync()
    .whereType<File>()
    .map((e) => e.path)
    .map(basenameWithoutExtension)
    .toList();
