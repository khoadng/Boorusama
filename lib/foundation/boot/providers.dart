// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../filesystem.dart';
import 'init.dart';

export 'init.dart';

final isFossBuildProvider = Provider<bool>((ref) {
  throw UnimplementedError();
});

final dbPathProvider = FutureProvider<String>((ref) async {
  final fs = ref.watch(appFileSystemProvider);
  final path = await initDbDirectory(fs);

  return path;
});
