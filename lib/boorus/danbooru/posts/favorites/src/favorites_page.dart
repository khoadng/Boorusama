// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/failsafe.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../router.dart';
import '../../listing/widgets.dart';
import '../../post/providers.dart';
import 'favorite.dart';

class DanbooruFavoritesPage extends ConsumerWidget {
  const DanbooruFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

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
    final config = ref.watchConfigSearch;
    final query = buildFavoriteQuery(username);
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => postRepo.getPosts(query, page),
        builder: (context, controller) => PostGrid(
          controller: controller,
          itemBuilder:
              (context, index, multiSelectController, scrollController) =>
                  DefaultDanbooruImageGridItem(
            index: index,
            multiSelectController: multiSelectController,
            autoScrollController: scrollController,
            controller: controller,
          ),
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
