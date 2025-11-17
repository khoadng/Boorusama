// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

final persistentCacheBoxProvider = FutureProvider<Box<String>>((ref) async {
  final appDir = await getApplicationDocumentsDirectory();
  final box = await Hive.openBox<String>(
    'app_cache',
    path: appDir.path,
  );

  ref.onDispose(() async {
    await box.close();
  });

  return box;
});
