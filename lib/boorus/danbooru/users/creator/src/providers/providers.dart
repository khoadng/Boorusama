// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/foundation/loggers.dart';

final danbooruCreatorHiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

Future<Override> createCreatorBoxOverride({
  required BooruConfig? initialConfig,
  required Directory tempPath,
  required BootLogger bootLogger,
}) async {
  bootLogger.l('Initialize danbooru creator box');
  final danbooruCreatorBox = await Hive.openBox(
    '${Uri.encodeComponent(initialConfig?.url ?? 'danbooru')}_creators_v1',
    path: tempPath.path,
  );

  return danbooruCreatorHiveBoxProvider.overrideWithValue(danbooruCreatorBox);
}
