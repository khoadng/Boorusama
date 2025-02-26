// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../backups/data_io_handler.dart';
import '../../../backups/providers.dart';
import '../../../info/device_info.dart';
import 'data/favorite_tag_hive_object.dart';
import 'data/favorite_tag_repository_hive.dart';
import 'favorite_tag.dart';
import 'favorite_tag_io_handler.dart';

final favoriteTagRepoProvider =
    FutureProvider<FavoriteTagRepository>((ref) async {
  final adapter = FavoriteTagHiveObjectAdapter();

  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }

  final favoriteTagsBox =
      await Hive.openBox<FavoriteTagHiveObject>('favorite_tags');
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  ref.onDispose(() async {
    await favoriteTagsBox.close();
  });

  return favoriteTagsRepo;
});

final favoriteTagsIOHandlerProvider = Provider<FavoriteTagsIOHandler>(
  (ref) => FavoriteTagsIOHandler(
    handler: DataIOHandler.file(
      converter: ref.watch(
        defaultBackupConverterProvider(1),
      ),
      deviceInfo: ref.watch(deviceInfoProvider),
      prefixName: 'boorusama_favorite_tags',
    ),
  ),
);
