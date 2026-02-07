// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

final persistentCacheBoxProvider = FutureProvider<Box<String>>((ref) async {
  final box = await Hive.openBox<String>('app_cache');

  ref.onDispose(() async {
    await box.close();
  });

  return box;
});
