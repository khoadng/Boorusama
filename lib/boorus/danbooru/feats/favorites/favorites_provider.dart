// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruFavoriteRepoProvider =
    Provider.family<FavoritePostRepository, BooruConfig>((ref, config) {
  return FavoritePostRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});

// Provider to check if a post is favorited
final danbooruFavoritesProvider =
    NotifierProvider.family<FavoritesNotifier, Map<int, bool>, BooruConfig>(
  FavoritesNotifier.new,
  dependencies: [
    danbooruFavoriteRepoProvider,
    currentBooruConfigProvider,
  ],
);

// Provider to check a single post is favorited or not
final danbooruFavoriteProvider = Provider.autoDispose.family<bool, int>(
  (ref, postId) {
    final config = ref.watchConfig;
    return ref.watch(danbooruFavoritesProvider(config))[postId] ?? false;
  },
  dependencies: [
    danbooruFavoritesProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruFavoriteCheckerProvider =
    Provider.family<FavoriteChecker, BooruConfig>((ref, config) {
  final favorites = ref.watch(danbooruFavoritesProvider(config));

  return (postId) => favorites[postId] ?? false;
});
