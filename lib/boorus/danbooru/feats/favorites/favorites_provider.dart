// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';

final danbooruFavoriteRepoProvider = Provider<FavoritePostRepository>((ref) {
  return FavoritePostRepositoryApi(
    ref.watch(danbooruClientProvider),
  );
});

// Provider to check if a post is favorited
final danbooruFavoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<int, bool>>(
  FavoritesNotifier.new,
  dependencies: [
    danbooruFavoriteRepoProvider,
    booruUserIdentityProviderProvider,
    currentBooruConfigProvider,
  ],
);

// Provider to check a single post is favorited or not
final danbooruFavoriteProvider = Provider.family<bool, int>(
  (ref, postId) => ref.watch(danbooruFavoritesProvider)[postId] ?? false,
  dependencies: [
    danbooruFavoritesProvider,
  ],
);

final danbooruFavoriteCheckerProvider = Provider<FavoriteChecker>((ref) {
  final favorites = ref.watch(danbooruFavoritesProvider);

  return (postId) => favorites[postId] ?? false;
});
