// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/string.dart';
import 'widgets/pools/pool_grid_item.dart';

class PoolSearchPage extends ConsumerStatefulWidget {
  const PoolSearchPage({super.key});

  @override
  ConsumerState<PoolSearchPage> createState() => _PoolSearchPageState();
}

class _PoolSearchPageState extends ConsumerState<PoolSearchPage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(danbooruPoolSearchModeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _SearchBar(textEditingController: textEditingController),
      ),
      body: switch (mode) {
        PoolSearchMode.suggestion => _SuggestionView(
            textEditingController: textEditingController,
          ),
        PoolSearchMode.result => const _ResultView(),
      },
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(danbooruPoolQueryProvider);
    final config = ref.watchConfig;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomScrollView(
        slivers: [
          RiverPagedBuilder.autoDispose(
            firstPageProgressIndicatorBuilder: (context, controller) =>
                const CircularProgressIndicator.adaptive(),
            pullToRefresh: false,
            firstPageKey: PoolKey(page: 1, name: query),
            provider: danbooruPoolsSearchResultProvider(config),
            itemBuilder: (context, pool, index) => PoolGridItem(pool: pool),
            pagedBuilder: (controller, builder) => PagedSliverGrid(
              pagingController: controller,
              builderDelegate: builder,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionView extends ConsumerWidget {
  const _SuggestionView({
    required this.textEditingController,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    ref.listen(
      danbooruPoolQueryProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          ref.read(danbooruPoolsSearchProvider(config).notifier).load(
                PoolKey(page: 1, name: next),
                50,
              );
        }
      },
    );

    return RiverPagedBuilder.autoDispose(
      provider: danbooruPoolsSearchProvider(config),
      pagedBuilder: (controller, builder) => PagedListView(
        pagingController: controller,
        builderDelegate: builder,
      ),
      itemBuilder: (context, pool, index) => ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
          pool.name.replaceUnderscoreWithSpace(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _poolCategoryToColor(pool.category),
          ),
        ),
        trailing: Text(
          NumberFormat.compact().format(pool.postCount),
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          textEditingController.text = pool.name.replaceUnderscoreWithSpace();
          ref.read(danbooruPoolQueryProvider.notifier).state = pool.name;
          ref.read(danbooruPoolSearchModeProvider.notifier).state =
              PoolSearchMode.result;
        },
      ),
      firstPageKey: const PoolKey(page: 1),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar({
    required this.textEditingController,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(danbooruPoolQueryProvider);

    return BooruSearchBar(
      leading: IconButton(
        splashRadius: 16,
        onPressed: () => context.navigator.pop(),
        icon: const Icon(
          Icons.arrow_back,
        ),
      ),
      queryEditingController: textEditingController,
      autofocus: true,
      trailing: query.isNotEmpty
          ? IconButton(
              onPressed: () {
                textEditingController.clear();
                ref.read(danbooruPoolQueryProvider.notifier).state = '';
              },
              icon: const Icon(Icons.close),
            )
          : const SizedBox.shrink(),
      onChanged: (value) =>
          ref.read(danbooruPoolQueryProvider.notifier).state = value,
      onSubmitted: (value) {
        ref.read(danbooruPoolSearchModeProvider.notifier).state =
            PoolSearchMode.result;
      },
      hintText: 'pool.search.hint'.tr(),
      onTap: () => ref.read(danbooruPoolSearchModeProvider.notifier).state =
          PoolSearchMode.suggestion,
    );
  }
}

Color _poolCategoryToColor(PoolCategory category) => switch (category) {
      PoolCategory.series => TagColors.dark().copyright,
      _ => TagColors.dark().general,
    };
