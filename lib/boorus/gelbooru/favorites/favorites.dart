// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/scaffolds/scaffolds.dart';
import '../gelbooru.dart';

class GelbooruFavoritesPage extends ConsumerWidget {
  const GelbooruFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      builder: (_) => GelbooruFavoritesPageInternal(
        uid: config.login!,
      ),
    );
  }
}

class GelbooruFavoritesPageInternal extends ConsumerWidget {
  const GelbooruFavoritesPageInternal({
    required this.uid,
    super.key,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'fav:$uid';
    final notifier = ref.watch(favoritesProvider(config.auth).notifier);
    final repo = ref.watch(gelbooruPostRepoProvider(config));

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) => TaskEither.Do(($) async {
        final r = await $(repo.getPosts(query, page));

        // all posts from this page are already favorited by the user
        notifier.preloadInternal(
          r.posts,
          selfFavorited: (post) => true,
        );

        return r;
      }),
    );
  }
}

class GelbooruFavoriteRepository extends FavoriteRepository<GelbooruPost> {
  GelbooruFavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  GelbooruClient get client => ref.read(gelbooruClientProvider(config));

  @override
  bool canFavorite() => client.canFavorite;

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async =>
      client.addFavorite(postId: postId).then(
            (value) => switch (value) {
              GelbooruFavoriteStatus.success => AddFavoriteStatus.success,
              GelbooruFavoriteStatus.alreadyFavorited =>
                AddFavoriteStatus.alreadyExists,
              _ => AddFavoriteStatus.failure,
            },
          );

  @override
  Future<bool> removeFromFavorites(int postId) async => client
      .removeFavorite(postId: postId)
      .then((value) => true)
      .catchError((e) => false);

  @override
  bool isPostFavorited(GelbooruPost post) => false;
}
