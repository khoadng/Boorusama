// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/boorus/core/pages/search/search_button.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/search_scope.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class MoebooruSearchPage extends ConsumerStatefulWidget {
  const MoebooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(
    BuildContext context,
    WidgetRef ref, {
    String? tag,
  }) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: MoebooruProvider(
        builder: (gcontext) {
          return CustomContextMenuOverlay(
            child: MoebooruSearchPage(
              metatagHighlightColor: context.colorScheme.primary,
              initialQuery: tag,
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<MoebooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<MoebooruSearchPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.read(currentBooruConfigProvider);

    return SearchScope(
      initialQuery: widget.initialQuery,
      builder: (state, focus, controller, selectedTagController,
              searchController, allowSearch) =>
          switch (state) {
        DisplayState.options => Scaffold(
            floatingActionButton: SearchButton(
              allowSearch: allowSearch,
              onSearch: searchController.search,
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
              child: SearchAppBar(
                focusNode: focus,
                queryEditingController: controller,
                onSubmitted: (value) => searchController.submit(value),
                onBack: () => state != DisplayState.options
                    ? searchController.resetToOptions()
                    : context.navigator.pop(),
              ),
            ),
            body: SafeArea(
              child: CustomScrollView(slivers: [
                SliverPinnedHeader(
                  child: SelectedTagListWithData(
                    controller: selectedTagController,
                    onDeleted: (value) => searchController.resetToOptions(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SearchLandingView(
                    onHistoryCleared: () => ref
                        .read(searchHistoryProvider.notifier)
                        .clearHistories(),
                    onHistoryRemoved: (value) => ref
                        .read(searchHistoryProvider.notifier)
                        .removeHistory(value.query),
                    onHistoryTap: (value) =>
                        searchController.tapHistoryTag(value),
                    onTagTap: (value) => searchController.tapTag(value),
                  ),
                ),
              ]),
            ),
          ),
        DisplayState.suggestion => Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
              child: SearchAppBar(
                focusNode: focus,
                queryEditingController: controller,
                onSubmitted: (value) => searchController.submit(value),
                onBack: () => state != DisplayState.options
                    ? searchController.resetToOptions()
                    : context.navigator.pop(),
              ),
            ),
            body: DefaultSearchSuggestionView(
              selectedTagController: selectedTagController,
              textEditingController: controller,
              searchController: searchController,
            ),
          ),
        DisplayState.result => PostScope(
            fetcher: (page) =>
                ref.watch(postRepoProvider(config)).getPostsFromTags(
                      selectedTagController.rawTags.join(' '),
                      page,
                    ),
            builder: (context, controller, errors) => MoebooruInfinitePostList(
              errors: errors,
              controller: controller,
              sliverHeaderBuilder: (context) => [
                SearchAppBarResultView(
                  onTap: () => searchController.goToSuggestions(),
                  onBack: () => searchController.resetToOptions(),
                ),
                SliverToBoxAdapter(
                    child: SelectedTagListWithData(
                  controller: selectedTagController,
                  onDeleted: (value) => searchController.resetToOptions(),
                )),
                const SliverToBoxAdapter(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
      },
    );
  }
}
