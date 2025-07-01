// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../posts/listing/widgets.dart';
import '../posts/post/post.dart';
import '../search/search/routes.dart';
import '../widgets/widgets.dart';

class FavoritesPageScaffold<T extends Post> extends ConsumerWidget {
  const FavoritesPageScaffold({
    required this.fetcher,
    required this.favQueryBuilder,
    super.key,
  });

  final PostsOrError<T> Function(int page) fetcher;
  final String Function()? favQueryBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => fetcher(page),
        builder: (context, controller) => PostGrid(
          controller: controller,
          sliverHeaders: [
            SliverAppBar(
              title: const Text('profile.favorites').tr(),
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
