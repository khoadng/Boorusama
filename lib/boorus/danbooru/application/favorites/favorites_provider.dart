// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/favorites/favorites.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'favorites_notifier.dart';

final danbooruFavoriteRepoProvider = Provider<FavoritePostRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfigRepo = ref.watch(currentBooruConfigRepoProvider);

  return FavoritePostRepositoryApi(api, booruConfigRepo);
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
