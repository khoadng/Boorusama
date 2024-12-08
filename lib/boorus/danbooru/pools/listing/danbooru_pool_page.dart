// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/i18n.dart';
import '../_internal/pool_page_sliver_grid.dart';
import '../_internal/providers.dart';
import '../pool/danbooru_pool.dart';
import 'pool_options_header.dart';

class DanbooruPoolPage extends StatelessWidget {
  const DanbooruPoolPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        bottom: false,
        child: _PostList(),
      ),
    );
  }
}

class _PostList extends ConsumerWidget {
  const _PostList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              titleSpacing: 0,
              backgroundColor: context.colorScheme.surface,
              title: const Text('pool.pool_gallery').tr(),
              actions: const [
                PoolSearchButton(),
              ],
            ),
            SliverPinnedHeader(
              child: ColoredBox(
                color: context.colorScheme.surface,
                child: DefaultTabController(
                  initialIndex:
                      ref.watch(danbooruSelectedPoolCategoryProvider) ==
                              DanbooruPoolCategory.collection
                          ? 0
                          : 1,
                  length: 2,
                  child: TabBar(
                    isScrollable: true,
                    onTap: (value) {
                      ref
                          .read(danbooruSelectedPoolCategoryProvider.notifier)
                          .state = value ==
                              0
                          ? DanbooruPoolCategory.collection
                          : DanbooruPoolCategory.series;
                    },
                    tabs: [
                      for (final e in DanbooruPoolCategory.values
                          .where((e) => e != DanbooruPoolCategory.unknown))
                        Tab(
                          text: 'pool.category.${e.name}'.tr(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PoolOptionsHeader(),
            ),
            PoolPagedSliverGrid(
              order: ref.watch(danbooruSelectedPoolOrderProvider),
              category: ref.watch(danbooruSelectedPoolCategoryProvider),
              constraints: constraints,
            ),
          ],
        );
      },
    );
  }
}

class PoolSearchButton extends ConsumerWidget {
  const PoolSearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      splashRadius: 24,
      onPressed: () {
        goToPoolSearchPage(context, ref);
      },
      icon: const Icon(Symbols.search),
    );
  }
}
