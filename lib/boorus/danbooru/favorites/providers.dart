// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/functional.dart';
import 'favorite.dart';
import 'favorite_post_repository_api.dart';
import 'favorites_notifier.dart';

final danbooruFavoriteRepoProvider =
    Provider.family<FavoritePostRepository, BooruConfigAuth>((ref, config) {
  return FavoritePostRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});

// Provider to check if a post is favorited
final danbooruFavoritesProvider = NotifierProvider.family<FavoritesNotifier,
    IMap<int, bool>, BooruConfigAuth>(
  FavoritesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

// Provider to check a single post is favorited or not
final danbooruFavoriteProvider = Provider.autoDispose.family<bool, int>(
  (ref, postId) {
    final config = ref.watchConfigAuth;
    return ref.watch(danbooruFavoritesProvider(config))[postId] ?? false;
  },
);
