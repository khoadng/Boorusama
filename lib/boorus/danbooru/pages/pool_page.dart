// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/pools/pool_grid_item.dart';
import 'widgets/pools/pool_options_header.dart';
import 'widgets/pools/pool_search_button.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pool.pool_gallery').tr(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          PoolSearchButton(),
        ],
      ),
      body: const SafeArea(
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
    final config = ref.watchConfig;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: PoolOptionsHeader(),
        ),
        RiverPagedBuilder.autoDispose(
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
              crossAxisCount: switch (Screen.of(context).size) {
                ScreenSize.small => 2,
                ScreenSize.medium => 3,
                ScreenSize.large => 5,
                ScreenSize.veryLarge => 6,
              },
              childAspectRatio: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
