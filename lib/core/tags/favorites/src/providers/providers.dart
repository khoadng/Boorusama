// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../data/favorite_tag_hive_object.dart';
import '../data/favorite_tag_repository_hive.dart';
import '../types/favorite_tag.dart';

final favoriteTagRepoProvider = FutureProvider<FavoriteTagRepository>((
  ref,
) async {
  final adapter = FavoriteTagHiveObjectAdapter();

  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }

  final favoriteTagsBox = await Hive.openBox<FavoriteTagHiveObject>(
    'favorite_tags',
  );
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  ref.onDispose(() async {
    await favoriteTagsBox.close();
  });

  return favoriteTagsRepo;
});
