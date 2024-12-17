// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';

final danbooruCreatorHiveBoxProvider =
    FutureProvider.family<Box, BooruConfigAuth>((ref, config) async {
  final tempPath = await getTemporaryDirectory();

  final danbooruCreatorBox = await Hive.openBox(
    '${Uri.encodeComponent(config.url)}_creators_v1',
    path: tempPath.path,
  );

  return danbooruCreatorBox;
});
