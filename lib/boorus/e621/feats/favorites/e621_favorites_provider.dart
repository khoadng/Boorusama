// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

final e621FavoritesRepoProvider = Provider<E621FavoritesRepository>((ref) {
  return E621FavoritesRepositoryApi(
    ref.read(e621ClientProvider),
    ref.read(currentBooruConfigProvider),
    ref.read(e621PostRepoProvider),
  );
});

final e621FavoritesProvider =
    NotifierProvider<E621FavoritesNotifier, IMap<int, bool>>(
  E621FavoritesNotifier.new,
);

final e621FavoriteProvider = Provider.family<bool, int>((ref, postId) {
  final favorites = ref.watch(e621FavoritesProvider);
  return favorites[postId] ?? false;
});

final e621FavoriteCheckerProvider = Provider<FavoriteChecker>((ref) {
  final favorites = ref.watch(e621FavoritesProvider);

  return (postId) => favorites[postId] ?? false;
});
