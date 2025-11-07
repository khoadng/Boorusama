// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/listing/types.dart';
import '../../../../../../core/posts/pools/widgets.dart';
import '../../../../../../core/settings/providers.dart';
import '../../../details/routes.dart';
import '../../providers.dart';
import '../../types.dart';
import 'pool_image.dart';

const _kLabelOffset = 0.2;

class PoolPagedSliverGrid extends ConsumerStatefulWidget {
  const PoolPagedSliverGrid({
    required this.constraints,
    required this.order,
    required this.category,
    super.key,
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

  late final controller = PagingController<int, DanbooruPool>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => _fetchPage(
      pageKey,
      category,
      order,
      name: name,
      description: description,
    ),
  );

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

  Future<List<DanbooruPool>> _fetchPage(
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
        unawaited(
          ref.read(danbooruPoolCoversProvider(config).notifier).load(newItems),
        );
      }

      return newItems;
    } catch (error) {
      return Future.error(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageGridSpacing = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridSpacing),
    );
    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridPadding),
    );
    final gridSize = ref.watch(
      imageListingSettingsProvider.select((value) => value.gridSize),
    );
    final imageGridAspectRatio =
        ref.watch(
          imageListingSettingsProvider.select(
            (value) => value.imageGridAspectRatio,
          ),
        ) -
        _kLabelOffset;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: imageGridPadding),
      sliver: PagingListener(
        controller: controller,
        builder: (context, state, fetchNextPage) => PagedSliverGrid(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<DanbooruPool>(
            itemBuilder: (context, pool, index) => PoolGridItem(
              image: PoolImage(pool: pool),
              onTap: () => goToPoolDetailPage(ref, pool),
              total: pool.postCount,
              name: pool.name,
            ),
            firstPageProgressIndicatorBuilder: (context) => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculateGridCount(
              widget.constraints.maxWidth,
              gridSize,
            ),
            childAspectRatio: imageGridAspectRatio,
            mainAxisSpacing: imageGridSpacing,
            crossAxisSpacing: imageGridSpacing,
          ),
        ),
      ),
    );
  }
}
