// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';

final danbooruFavoriteRepoProvider = Provider<FavoritePostRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return FavoritePostRepositoryApi(api, booruConfig);
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
