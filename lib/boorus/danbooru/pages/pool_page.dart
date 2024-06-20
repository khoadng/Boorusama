// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/settings/settings.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
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
                    isScrollable: true,
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

class PoolPagedSliverGrid extends ConsumerStatefulWidget {
  const PoolPagedSliverGrid({
    super.key,
    required this.constraints,
    required this.order,
    required this.category,
    this.name,
    this.description,
  });

  final BoxConstraints constraints;
  final PoolOrder order;
  final PoolCategory category;
  final String? name;
  final String? description;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PoolPagedSliverGridState();
}

class _PoolPagedSliverGridState extends ConsumerState<PoolPagedSliverGrid> {
  late var order = widget.order;
  late var category = widget.category;
  late var name = widget.name;
  late var description = widget.description;

  final controller = PagingController<int, Pool>(
    firstPageKey: 1,
  );

  @override
  void initState() {
    controller.addPageRequestListener((pageKey) {
      _fetchPage(
        pageKey,
        category,
        order,
        name: name,
        description: description,
      );
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PoolPagedSliverGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.order != widget.order ||
        oldWidget.category != widget.category) {
      order = widget.order;
      category = widget.category;
      controller.refresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> _fetchPage(
    int pageKey,
    PoolCategory category,
    PoolOrder order, {
    String? name,
    String? description,
  }) async {
    final config = ref.readConfig;
    final repo = ref.read(danbooruPoolRepoProvider(config));
    try {
      final newItems = await repo.getPools(
        pageKey,
        category: category,
        order: order,
        name: name,
        description: description,
      );

      const loadCovers = true;

      if (loadCovers) {
        ref.read(danbooruPoolCoversProvider(config).notifier).load(newItems);
      }

      final isLastPage = newItems.isEmpty;
      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageGridSpacing = ref.watch(gridSpacingSettingsProvider);
    final imageGridPadding = ref.watch(gridPaddingSettingsProvider);
    final gridSize = ref.watch(gridSizeSettingsProvider);
    final imageGridAspectRatio =
        ref.watch(gridAspectRatioSettingsProvider) - _kLabelOffset;

    final crossAxisCount = calculateGridCount(
      widget.constraints.maxWidth,
      gridSize,
    );

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: imageGridPadding),
      sliver: PagedSliverGrid(
        pagingController: controller,
        builderDelegate: PagedChildBuilderDelegate<Pool>(
          itemBuilder: (context, pool, index) => PoolGridItem(pool: pool),
          firstPageProgressIndicatorBuilder: (context) => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: imageGridAspectRatio,
          mainAxisSpacing: imageGridSpacing,
          crossAxisSpacing: imageGridSpacing,
        ),
      ),
    );
  }
}
