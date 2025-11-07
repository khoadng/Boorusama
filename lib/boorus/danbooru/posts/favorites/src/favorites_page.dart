// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/auth/widgets.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../listing/widgets.dart';
import '../../post/providers.dart';
import 'types/favorite.dart';

class DanbooruFavoritesPage extends ConsumerWidget {
  const DanbooruFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      builder: (_) => DanbooruFavoritesPageInternal(
        username: config.login!,
      ),
    );
  }
}

class DanbooruFavoritesPageInternal extends ConsumerWidget {
  const DanbooruFavoritesPageInternal({
    required this.username,
    super.key,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = buildFavoriteQuery(username);
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => postRepo.getPosts(query, page),
        builder: (context, controller) => PostGrid(
          controller: controller,
          itemBuilder: (context, index, scrollController, useHero) =>
              DanbooruPostListingContextMenu(
                index: index,
                controller: controller,
                child: DefaultDanbooruImageGridItem(
                  index: index,
                  autoScrollController: scrollController,
                  controller: controller,
                  useHero: useHero,
                ),
              ),
          sliverHeaders: [
            SliverAppBar(
              title: Text(context.t.profile.favorites),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Symbols.search),
                  onPressed: () {
                    goToSearchPage(
                      ref,
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
