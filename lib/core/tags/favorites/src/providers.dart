// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../foundation/device_info.dart';
import '../../../../foundation/loggers.dart';
import '../../../backups/data_io_handler.dart';
import '../../../backups/providers.dart';
import 'data/favorite_tag_hive_object.dart';
import 'data/favorite_tag_repository_hive.dart';
import 'favorite_tag.dart';
import 'favorite_tag_io_handler.dart';

final favoriteTagRepoProvider =
    Provider<FavoriteTagRepository>((ref) => throw UnimplementedError());

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

Future<Override> createFavoriteTagOverride({
  required BootLogger bootLogger,
}) async {
  bootLogger.l('Register favorite tag adapter');
  Hive.registerAdapter(FavoriteTagHiveObjectAdapter());

  bootLogger.l('Initialize favorite tag repository');
  final favoriteTagsBox =
      await Hive.openBox<FavoriteTagHiveObject>('favorite_tags');
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  return favoriteTagRepoProvider.overrideWithValue(favoriteTagsRepo);
}
