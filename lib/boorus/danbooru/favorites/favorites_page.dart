// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruFavoritesPage extends ConsumerWidget {
  const DanbooruFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return BooruConfigAuthFailsafe(
      child: DanbooruFavoritesPageInternal(
        username: config.login!,
      ),
    );
  }
}

class DanbooruFavoritesPageInternal extends ConsumerWidget {
  const DanbooruFavoritesPageInternal({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    final query = buildFavoriteQuery(username);
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => postRepo.getPosts(query, page),
        builder: (context, controller, errors) => DanbooruInfinitePostList(
          errors: errors,
          controller: controller,
          sliverHeaders: [
            SliverAppBar(
              title: const Text('profile.favorites').tr(),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Symbols.search),
                  onPressed: () {
                    goToSearchPage(
                      context,
                      tag: query,
                    );
                  },
                ),
              ],
            ),
            const SliverSizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

class DanbooruQuickFavoriteButton extends ConsumerWidget {
  const DanbooruQuickFavoriteButton({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFaved =
        post.isBanned ? false : ref.watch(danbooruFavoriteProvider(post.id));

    return QuickFavoriteButton(
      isFaved: isFaved,
      onFavToggle: (isFaved) async {
        if (!isFaved) {
          ref.danbooruFavorites.remove(post.id);
        } else {
          ref.danbooruFavorites.add(post.id);
        }
      },
    );
  }
}
