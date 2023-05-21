// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'pool_grid_item.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomScrollView(
        slivers: [
          RiverPagedBuilder.autoDispose(
            firstPageProgressIndicatorBuilder: (context, controller) =>
                const CircularProgressIndicator.adaptive(),
            pullToRefresh: false,
            firstPageKey: PoolKey(page: 1, name: query),
            provider: danbooruPoolsSearchResultProvider,
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
    ref.listen(
      danbooruPoolQueryProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          ref.read(danbooruPoolsSearchProvider.notifier).load(
                PoolKey(page: 1, name: next),
                50,
              );
        }
      },
    );

    return RiverPagedBuilder.autoDispose(
      provider: danbooruPoolsSearchProvider,
      pagedBuilder: (controller, builder) => PagedListView(
        pagingController: controller,
        builderDelegate: builder,
      ),
      itemBuilder: (context, pool, index) => ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
          pool.name.removeUnderscoreWithSpace(),
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
          textEditingController.text = pool.name.replaceAll('_', ' ');
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
        onPressed: () => Navigator.of(context).pop(),
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
