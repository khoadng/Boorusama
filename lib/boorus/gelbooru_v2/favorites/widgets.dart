// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/widgets.dart';
import '../../../core/posts/listing/widgets.dart';
import '../../../core/posts/post/types.dart';
import '../../../foundation/toast.dart';
import '../gelbooru_v2_provider.dart';
import '../posts/providers.dart';
import 'providers.dart';

class GelbooruV2FavoritesPage extends ConsumerWidget {
  const GelbooruV2FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final gelbooruV2 = ref.watch(gelbooruV2Provider);

    return BooruConfigAuthFailsafe(
      builder: (_) => switch (gelbooruV2
          .getCapabilitiesForSite(config.url)
          ?.favorites
          ?.endpointType) {
        EndpointType.html => GelbooruV2FavoritesPageHtml(uid: config.login!),
        _ => GelbooruV2FavoritesPageApi(uid: config.login!),
      },
    );
  }
}

class GelbooruV2FavoritesPageApi extends ConsumerWidget {
  const GelbooruV2FavoritesPageApi({
    required this.uid,
    super.key,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'fav:$uid';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(gelbooruV2PostRepoProvider(config)).getPosts(query, page),
    );
  }
}

class GelbooruV2FavoritesPageHtml extends ConsumerWidget {
  const GelbooruV2FavoritesPageHtml({
    required this.uid,
    super.key,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final repo = ref.watch(gelbooruV2FavoritesPostRepoProvider((config, uid)));
    final notifier = ref.watch(favoritesProvider(config.auth).notifier);

    return FavoritesPageScaffold(
      favQueryBuilder: null,
      itemBuilder:
          (context, index, autoScrollController, controller, useHero) =>
              GeneralPostContextMenu(
                index: index,
                controller: controller,
                child: DefaultImageGridItem(
                  index: index,
                  autoScrollController: autoScrollController,
                  controller: controller,
                  useHero: useHero,
                  config: config.auth,
                  onTap: () {
                    final post = controller.items.elementAtOrNull(index);
                    if (post == null) {
                      showErrorToast(context, 'Post not found'.hc);
                      return;
                    }

                    goToSinglePostDetailsPage(
                      ref: ref,
                      postId: NumericPostId(post.id),
                      configSearch: config,
                    );
                  },
                ),
              ),
      fetcher: (page) => TaskEither.Do(($) async {
        // Just a placeholder since we can't really search with tags
        final r = await $(repo.getPosts('', page));

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
