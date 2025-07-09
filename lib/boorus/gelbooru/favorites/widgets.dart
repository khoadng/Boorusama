// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/widgets.dart';
import '../posts/providers.dart';

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
