// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class E621FavoritesPage extends ConsumerWidget {
  const E621FavoritesPage({
    super.key,
  });

  static Widget of(BuildContext context) => const CustomContextMenuOverlay(
        child: E621FavoritesPage(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostScope(
      fetcher: (page) => ref.read(e621FavoritesRepoProvider).getFavorites(page),
      builder: (context, controller, errors) => InfinitePostListScaffold(
        errors: errors,
        controller: controller,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            title: const Text('profile.favorites').tr(),
            floating: true,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: context.theme.scaffoldBackgroundColor,
          ),
          const SliverSizedBox(height: 5),
        ],
        onPostTap:
            (context, posts, post, scrollController, settings, initialIndex) =>
                goToPostDetailsPage(
          context: context,
          posts: posts,
          initialIndex: initialIndex,
          scrollController: scrollController,
        ),
      ),
    );
  }
}
