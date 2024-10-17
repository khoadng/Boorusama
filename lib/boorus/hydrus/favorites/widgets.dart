// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/hydrus/hydrus.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'favorites.dart';

class HydrusFavoritesPage extends ConsumerWidget {
  const HydrusFavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ref.watch(ratingServiceNameProvider(config)).when(
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
    final config = ref.watchConfig;
    final isFaved = ref.watch(hydrusFavoriteProvider(post.id));
    final favNotifier = ref.watch(hydrusFavoritesProvider(config).notifier);

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
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final favoriteAdder = booruBuilder?.favoriteAdder;
    final favoriteRemover = booruBuilder?.favoriteRemover;

    return ref.watch(hydrusCanFavoriteProvider(config)).when(
          data: (canFavorite) =>
              canFavorite && favoriteAdder != null && favoriteRemover != null
                  ? QuickFavoriteButton(
                      isFaved: ref.watch(hydrusFavoriteProvider(post.id)),
                      onFavToggle: (isFaved) async {
                        if (isFaved) {
                          await favoriteAdder(post.id, ref);
                        } else {
                          await favoriteRemover(post.id, ref);
                        }
                      },
                    )
                  : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (error, _) => const SizedBox.shrink(),
        );
  }
}
