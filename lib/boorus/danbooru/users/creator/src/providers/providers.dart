// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../foundation/filesystem.dart';

final danbooruCreatorHiveBoxProvider =
    FutureProvider.family<Box, BooruConfigAuth>((ref, config) async {
      final fs = ref.read(appFileSystemProvider);
      final tempPath = await fs.getTemporaryPath();

      final danbooruCreatorBox = await Hive.openBox(
        '${Uri.encodeComponent(config.url)}_creators_v1',
        path: tempPath,
      );

      return danbooruCreatorBox;
    });
