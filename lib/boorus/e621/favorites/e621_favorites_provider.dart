// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/favorites/favorites.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/functional.dart';

final e621FavoritesRepoProvider =
    Provider.family<E621FavoritesRepository, BooruConfigAuth>((ref, config) {
  return E621FavoritesRepositoryApi(
    ref.watch(e621ClientProvider(config)),
  );
});

final e621FavoritesProvider = NotifierProvider.family<E621FavoritesNotifier,
    IMap<int, bool>, BooruConfigAuth>(
  E621FavoritesNotifier.new,
);

final e621FavoriteProvider =
    Provider.autoDispose.family<bool, int>((ref, postId) {
  final config = ref.watchConfigAuth;
  final favorites = ref.watch(e621FavoritesProvider(config));
  return favorites[postId] ?? false;
});
