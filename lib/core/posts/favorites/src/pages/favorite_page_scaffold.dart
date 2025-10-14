// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../search/search/routes.dart';
import '../../../../widgets/widgets.dart';
import '../../../listing/providers.dart';
import '../../../listing/widgets.dart';
import '../../../post/types.dart';

typedef IndexedSelectableFavoritesWidgetBuilder<T extends Post> =
    Widget Function(
      BuildContext context,
      int index,
      AutoScrollController autoScrollController,
      PostGridController<T> controller,
      bool useHero,
    );

class FavoritesPageScaffold<T extends Post> extends ConsumerWidget {
  const FavoritesPageScaffold({
    required this.fetcher,
    required this.favQueryBuilder,
    this.itemBuilder,
    super.key,
  });

  final PostsOrError<T> Function(int page) fetcher;
  final String Function()? favQueryBuilder;
  final IndexedSelectableFavoritesWidgetBuilder<T>? itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => fetcher(page),
        builder: (context, controller) => PostGrid(
          controller: controller,
          itemBuilder: itemBuilder != null
              ? (context, index, autoScrollController, useHero) => itemBuilder!(
                  context,
                  index,
                  autoScrollController,
                  controller,
                  useHero,
                )
              : null,
          sliverHeaders: [
            SliverAppBar(
              title: Text(context.t.profile.favorites),
              floating: true,
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Theme.of(context).colorScheme.surface,
              actions: [
                if (favQueryBuilder != null)
                  IconButton(
                    icon: const Icon(Symbols.search),
                    onPressed: () {
                      goToSearchPage(
                        ref,
                        tag: favQueryBuilder!(),
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
