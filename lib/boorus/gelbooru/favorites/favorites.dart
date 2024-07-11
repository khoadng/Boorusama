// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client_favorites.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/functional.dart';

class GelbooruFavoritesPage extends ConsumerWidget {
  const GelbooruFavoritesPage({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'fav:$uid';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) => TaskEither.Do(($) async {
        final r = await $(
            ref.read(gelbooruPostRepoProvider(config)).getPosts(query, page));

        // all posts from this page are already favorited by the user
        ref.read(gelbooruFavoritesProvider(config).notifier).preloadInternal(
              r.posts,
              selfFavorited: (post) => true,
            );

        return r;
      }),
    );
  }
}

class GelbooruFavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfig>
    with FavoritesNotifierMixin {
  @override
  IMap<int, bool> build(BooruConfig arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  @override
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder =>
      (postId) => ref
          .read(
            gelbooruClientProvider(ref.watchConfig),
          )
          .addFavorite(postId: postId)
          .then((value) => switch (value) {
                GelbooruFavoriteStatus.success => AddFavoriteStatus.success,
                GelbooruFavoriteStatus.alreadyFavorited =>
                  AddFavoriteStatus.alreadyExists,
                _ => AddFavoriteStatus.failure,
              });

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) => ref
      .read(
        gelbooruClientProvider(ref.watchConfig),
      )
      .removeFavorite(postId: postId)
      .then((value) => true)
      .catchError((e) => false);

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}

final gelbooruFavoritesProvider = NotifierProvider.family<
    GelbooruFavoritesNotifier, IMap<int, bool>, BooruConfig>(
  GelbooruFavoritesNotifier.new,
);

final gelbooruFavoriteProvider =
    Provider.autoDispose.family<bool, int>((ref, postId) {
  final config = ref.watchConfig;
  final favorites = ref.watch(gelbooruFavoritesProvider(config));
  return favorites[postId] ?? false;
});
