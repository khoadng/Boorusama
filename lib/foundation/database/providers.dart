// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../path/app_storage.dart';

const _kFolderName = 'data';

final databaseFolderPathProvider = FutureProvider<String>((ref) async {
  final basePath = await getAppStoragePath();
  return join(basePath, _kFolderName);
});
