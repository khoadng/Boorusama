// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'infinite_post_list_scaffold.dart';

class FavoritesPageScaffold<T extends Post> extends ConsumerWidget {
  const FavoritesPageScaffold({
    super.key,
    required this.fetcher,
    required this.favQueryBuilder,
  });

  final PostsOrError<T> Function(int page) fetcher;
  final String Function() favQueryBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => fetcher(page),
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
              actions: [
                IconButton(
                  icon: const Icon(Symbols.search),
                  onPressed: () {
                    goToSearchPage(
                      context,
                      tag: favQueryBuilder(),
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
