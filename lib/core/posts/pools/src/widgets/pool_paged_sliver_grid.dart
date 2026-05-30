// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../listing/types.dart';
import '../../../../settings/providers.dart';
import '../../pool_grid_item.dart';

class PoolPagedSliverGridView<T> extends ConsumerStatefulWidget {
  const PoolPagedSliverGridView({
    required this.constraints,
    required this.fetchPage,
    required this.imageBuilder,
    required this.onTap,
    required this.total,
    required this.name,
    super.key,
    this.refreshKey,
  });

  final BoxConstraints constraints;
  final Object? refreshKey;
  final Future<List<T>> Function(WidgetRef ref, int page) fetchPage;
  final Widget Function(BuildContext context, T pool) imageBuilder;
  final void Function(WidgetRef ref, T pool) onTap;
  final int? Function(T pool) total;
  final String? Function(T pool) name;

  @override
  ConsumerState<PoolPagedSliverGridView<T>> createState() =>
      _PoolPagedSliverGridViewState<T>();
}

class _PoolPagedSliverGridViewState<T>
    extends ConsumerState<PoolPagedSliverGridView<T>> {
  late final controller = PagingController<int, T>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => widget.fetchPage(ref, pageKey),
  );

  @override
  void didUpdateWidget(covariant PoolPagedSliverGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshKey != widget.refreshKey) {
      controller.refresh();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        0.2;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: imageGridPadding),
      sliver: PagingListener(
        controller: controller,
        builder: (context, state, fetchNextPage) => PagedSliverGrid(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<T>(
            itemBuilder: (context, pool, index) => PoolGridItem(
              image: widget.imageBuilder(context, pool),
              onTap: () => widget.onTap(ref, pool),
              total: widget.total(pool),
              name: widget.name(pool),
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
