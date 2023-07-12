// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/default_search_suggestion_view.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/boorus/core/pages/search/search_button.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/result_header.dart';
import 'package:boorusama/boorus/core/widgets/search_scope.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/flutter.dart';

class GelbooruSearchPage extends ConsumerStatefulWidget {
  const GelbooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(
    WidgetRef ref,
    BuildContext context, {
    String? tag,
  }) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: GelbooruProvider(
        builder: (gcontext) {
          return CustomContextMenuOverlay(
            child: ProviderScope(
              overrides: [
                selectedTagsProvider.overrideWith(SelectedTagsNotifier.new)
              ],
              child: GelbooruSearchPage(
                metatagHighlightColor: context.colorScheme.primary,
                initialQuery: tag,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<GelbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<GelbooruSearchPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        ref
            .read(postCountStateProvider.notifier)
            .getPostCount([widget.initialQuery!]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchScope(
      initialQuery: widget.initialQuery,
      builder: (state, theme, focus, controller, tags, notifier) =>
          switch (state) {
        DisplayState.options => Scaffold(
            floatingActionButton: SearchButton(
              onSearch: () {
                final tags = ref.read(selectedTagsProvider);
                final rawTags = tags.map((e) => e.toString()).toList();
                ref.read(postCountStateProvider.notifier).getPostCount(rawTags);
                notifier.search();
              },
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
              child: SearchAppBar(
                focusNode: focus,
                queryEditingController: controller,
              ),
            ),
            body: SafeArea(
              child: CustomScrollView(slivers: [
                SliverPinnedHeader(
                  child: SelectedTagListWithData(tags: tags),
                ),
                const SliverToBoxAdapter(
                  child: SearchLandingView(),
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
              ),
            ),
            body: DefaultSearchSuggestionView(
              tags: tags,
            ),
          ),
        DisplayState.result => PostScope(
            fetcher: (page) => ref.watch(postRepoProvider).getPostsFromTags(
                  ref.read(selectedRawTagStringProvider).join(' '),
                  page,
                ),
            builder: (context, controller, errors) => GelbooruInfinitePostList(
              errors: errors,
              controller: controller,
              sliverHeaderBuilder: (context) => [
                const SearchAppBarResultView(),
                SliverToBoxAdapter(
                    child: SelectedTagListWithData(
                  tags: tags,
                )),
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ref.watch(currentBooruProvider).booruType ==
                          BooruType.gelbooru)
                        ResultHeaderWithProvider(
                          selectedTags: ref.watch(selectedRawTagStringProvider),
                        ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: PostGridConfigIconButton(),
                      ),
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
