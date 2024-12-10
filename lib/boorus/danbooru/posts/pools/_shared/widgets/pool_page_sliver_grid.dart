// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/pools/pool_grid_item.dart';
import 'package:boorusama/core/posts/listing/list.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import '../../details/providers.dart';
import '../../pool/pool.dart';
import '../../pool/providers.dart';
import '../providers/pool_covers_notifier.dart';
import 'pool_image.dart';

const double _kLabelOffset = 0.2;

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
  final DanbooruPoolOrder order;
  final DanbooruPoolCategory category;
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

  final controller = PagingController<int, DanbooruPool>(
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
    DanbooruPoolCategory category,
    DanbooruPoolOrder order, {
    String? name,
    String? description,
  }) async {
    final config = ref.readConfigSearch;
    final repo = ref.read(danbooruPoolRepoProvider(config.auth));
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
      if (mounted) {
        controller.error = error;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageGridSpacing = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridSpacing));
    final imageGridPadding = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridPadding));
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridAspectRatio = ref.watch(imageListingSettingsProvider
            .select((value) => value.imageGridAspectRatio)) -
        _kLabelOffset;

    final crossAxisCount = calculateGridCount(
      widget.constraints.maxWidth,
      gridSize,
    );

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: imageGridPadding),
      sliver: PagedSliverGrid(
        pagingController: controller,
        builderDelegate: PagedChildBuilderDelegate<DanbooruPool>(
          itemBuilder: (context, pool, index) =>
              DanbooruPoolGridItem(pool: pool),
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

class DanbooruPoolGridItem extends ConsumerWidget {
  const DanbooruPoolGridItem({
    super.key,
    required this.pool,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolGridItem(
      image: PoolImage(pool: pool),
      onTap: () => goToPoolDetailPage(context, pool),
      total: pool.postCount,
      name: pool.name,
    );
  }
}
