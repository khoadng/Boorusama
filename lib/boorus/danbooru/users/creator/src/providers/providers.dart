// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../foundation/filesystem.dart';
import '../data/factory.dart';

final danbooruCreatorBoxFactoryProvider = Provider<DanbooruCreatorBoxFactory>(
  (ref) => HiveDanbooruCreatorBoxFactory(
    fileSystem: ref.watch(appFileSystemProvider),
  ),
);

final danbooruCreatorHiveBoxProvider =
    FutureProvider.family<Box, BooruConfigAuth>((ref, config) async {
      final factory = ref.watch(danbooruCreatorBoxFactoryProvider);
      final danbooruCreatorBox = await factory.create(config);
      ref.onDispose(() => factory.dispose(danbooruCreatorBox));

      return danbooruCreatorBox;
    });
