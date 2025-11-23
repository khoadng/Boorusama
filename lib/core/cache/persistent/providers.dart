// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../foundation/path.dart';

final persistentCacheBoxProvider = FutureProvider<Box<String>>((ref) async {
  final appDir = await getAppDocumentsDirectory();
  final box = await Hive.openBox<String>(
    'app_cache',
    path: appDir?.path,
  );

  ref.onDispose(() async {
    await box.close();
  });

  return box;
});
