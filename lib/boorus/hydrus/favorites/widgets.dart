// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/favorites/favorite_post_button.dart';
import '../../../core/favorites/providers.dart';
import '../../../core/favorites/quick_favorite_button.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/scaffolds/scaffolds.dart';
import '../hydrus.dart';
import 'favorites.dart';

class HydrusFavoritesPage extends ConsumerWidget {
  const HydrusFavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return ref.watch(ratingServiceNameProvider(config.auth)).when(
          data: (serviceName) => serviceName == null || serviceName.isEmpty
              ? _buildError()
              : Builder(
                  builder: (context) {
                    final query = 'system:rating for $serviceName = like'
                        .replaceAll(' ', '_');
                    return FavoritesPageScaffold(
                      favQueryBuilder: () => query,
                      fetcher: (page) => ref
                          .read(hydrusPostRepoProvider(config))
                          .getPosts(query, page),
                    );
                  },
                ),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _buildError(),
        );
  }

  Widget _buildError() {
    return const Scaffold(
      body: Center(
        child: Text('Error: Cannot find any like/dislike rating service'),
      ),
    );
  }
}

class HydrusFavoritePostButton extends ConsumerWidget {
  const HydrusFavoritePostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final isFaved = ref.watch(favoriteProvider(post.id));
    final favNotifier = ref.watch(favoritesProvider(config).notifier);

    return FavoritePostButton(
      isFaved: isFaved,
      isAuthorized: config.apiKey?.isNotEmpty ?? false,
      addFavorite: () => favNotifier.add(post.id),
      removeFavorite: () => favNotifier.remove(post.id),
    );
  }
}

class HydrusQuickFavoriteButton extends ConsumerWidget {
  const HydrusQuickFavoriteButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(favoritesProvider(config).notifier);

    return ref.watch(hydrusCanFavoriteProvider(config)).when(
          data: (canFavorite) => canFavorite
              ? QuickFavoriteButton(
                  isFaved: ref.watch(favoriteProvider(post.id)),
                  onFavToggle: (isFaved) async {
                    if (isFaved) {
                      await notifier.add(post.id);
                    } else {
                      await notifier.remove(post.id);
                    }
                  },
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (error, _) => const SizedBox.shrink(),
        );
  }
}
