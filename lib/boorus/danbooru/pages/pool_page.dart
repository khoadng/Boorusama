// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'widgets/pools/pool_grid_item.dart';
import 'widgets/pools/pool_options_header.dart';
import 'widgets/pools/pool_search_button.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({
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

const double _kLabelOffset = 0.2;

class _PostList extends ConsumerWidget {
  const _PostList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final imageGridSpacing = ref.watch(gridSpacingSettingsProvider);
    final imageGridPadding = ref.watch(gridPaddingSettingsProvider);
    final imageGridAspectRatio =
        ref.watch(gridAspectRatioSettingsProvider) - _kLabelOffset;
    final gridSize = ref.watch(gridSizeSettingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = calculateGridCount(
          constraints.maxWidth,
          gridSize,
        );

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              titleSpacing: 0,
              backgroundColor: context.theme.scaffoldBackgroundColor,
              title: const Text('pool.pool_gallery').tr(),
              actions: const [
                PoolSearchButton(),
              ],
            ),
            SliverPinnedHeader(
              child: Container(
                color: context.colorScheme.surface,
                child: DefaultTabController(
                  initialIndex:
                      ref.watch(danbooruSelectedPoolCategoryProvider) ==
                              PoolCategory.collection
                          ? 0
                          : 1,
                  length: 2,
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    indicatorColor: context.colorScheme.onBackground,
                    labelColor: context.colorScheme.onBackground,
                    unselectedLabelColor:
                        context.colorScheme.onBackground.withOpacity(0.5),
                    onTap: (value) {
                      ref
                          .read(danbooruSelectedPoolCategoryProvider.notifier)
                          .state = value ==
                              0
                          ? PoolCategory.collection
                          : PoolCategory.series;
                    },
                    tabs: [
                      for (final e in PoolCategory.values
                          .where((e) => e != PoolCategory.unknown))
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
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: imageGridPadding),
              sliver: RiverPagedBuilder.autoDispose(
                firstPageProgressIndicatorBuilder: (context, controller) =>
                    const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                pullToRefresh: false,
                firstPageKey: const PoolKey(page: 1),
                provider: danbooruPoolsProvider(config),
                itemBuilder: (context, pool, index) => PoolGridItem(pool: pool),
                pagedBuilder: (controller, builder) => PagedSliverGrid(
                  pagingController: controller,
                  builderDelegate: builder,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: imageGridAspectRatio,
                    mainAxisSpacing: imageGridSpacing,
                    crossAxisSpacing: imageGridSpacing,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
