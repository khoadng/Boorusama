// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

final e621FavoritesRepoProvider =
    Provider.family<E621FavoritesRepository, BooruConfig>((ref, config) {
  return E621FavoritesRepositoryApi(
    ref.read(e621ClientProvider(config)),
  );
});

final e621FavoritesProvider = NotifierProvider.family<E621FavoritesNotifier,
    IMap<int, bool>, BooruConfig>(
  E621FavoritesNotifier.new,
);

final e621FavoriteProvider =
    Provider.autoDispose.family<bool, int>((ref, postId) {
  final config = ref.watchConfig;
  final favorites = ref.watch(e621FavoritesProvider(config));
  return favorites[postId] ?? false;
});

final e621FavoriteCheckerProvider =
    Provider.family<FavoriteChecker, BooruConfig>((ref, config) {
  final favorites = ref.watch(e621FavoritesProvider(config));

  return (postId) => favorites[postId] ?? false;
});
