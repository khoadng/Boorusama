// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

final databaseFolderPathProvider = FutureProvider<String>((ref) async {
  final applicationDocumentsDir = await getApplicationDocumentsDirectory();
  final dbFolderPath = join(applicationDocumentsDir.path, 'data');

  return dbFolderPath;
});
