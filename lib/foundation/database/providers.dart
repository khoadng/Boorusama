// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../filesystem.dart';

const _kFolderName = 'data';

final databaseFolderPathProvider = FutureProvider<String>((ref) async {
  final fs = ref.watch(appFileSystemProvider);
  final basePath = await fs.getAppStoragePath();
  return join(basePath, _kFolderName);
});
