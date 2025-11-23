// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'init.dart';

export 'init.dart';

final isFossBuildProvider = Provider<bool>((ref) {
  throw UnimplementedError();
});

final dbPathProvider = FutureProvider<String>((ref) async {
  final path = await initDbDirectory();

  return path;
});
