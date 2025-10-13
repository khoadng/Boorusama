// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../analytics/providers.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../configs/config.dart';
import '../../../../configs/ref.dart';
import '../../../../posts/count/widgets.dart';
import '../../../../posts/listing/providers.dart';
import '../../../../posts/post/post.dart';
import '../../../../settings/providers.dart';
import '../../../../tags/metatag/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../histories/providers.dart';
import '../../../selected_tags/providers.dart';
import '../../../selected_tags/tag.dart';
import '../../../suggestions/providers.dart';
import '../../../suggestions/widgets.dart';
import '../routes/params.dart';
import '../types/search_bar_position.dart';
import '../views/search_landing_view.dart';
import 'raw_search_page_scaffold.dart';
import 'raw_search_region.dart';
import 'search_button.dart';
import 'search_controller.dart';
import 'selected_tag_list_with_data.dart';

class SearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const SearchPageScaffold({
    required this.fetcher,
    required this.params,
    super.key,
    this.textMatchers,
    this.extraHeaders,
    this.itemBuilder,
    this.searchRegionBuilder,
    this.landingViewBuilder,
  });

  final SearchParams params;

  String? get initialQuery => params.query;
  int? get initialPage => params.page;
  int? get initialScrollPosition => params.scrollPosition;

  final List<Widget> Function(
    BuildContext context,
    PostGridController<T> postController,
  )?
  extraHeaders;

  final PostsOrErrorCore<T> Function(
    int page,
    SelectedTagController selectedTagController,
  )
  fetcher;

  final List<TextMatcher>? textMatchers;

  final IndexedSelectableSearchWidgetBuilder<T>? itemBuilder;

  final Widget Function(
    ValueNotifier<PostGridController<T>?> postController,
    SearchPageController controller,
  )?
  searchRegionBuilder;

  final Widget Function(
    SearchPageController controller,
  )?
  landingViewBuilder;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  late final SelectedTagController _tagsController;
  late final SearchPageController _controller;
  late final SelectionModeController _searchModeController;

  late final ValueNotifier<PostGridController<T>?> _postController;

  @override
  void initState() {
    super.initState();

    _searchModeController = SelectionModeController();
    final extractor = ref.read(
      metatagExtractorProvider(ref.readConfigAuth),
    );

    _tagsController = SelectedTagController(
      metatagExtractor: extractor,
    );

    _controller = SearchPageController(
      onSearch: () {
        ref
            .read(searchHistoryProvider.notifier)
            .addHistoryFromController(_tagsController);
      },
      metatagExtractor: extractor,
      textMatchers: widget.textMatchers,
      tagsController: _tagsController,
    );

    _postController = ValueNotifier(null);
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _controller.dispose();
    _searchModeController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawSearchPageScaffold(
      fetcher: widget.fetcher,
      params: widget.params,
      tagsController: _tagsController,
      controller: _controller,
      selectionModeController: _searchModeController,
      onQueryChanged: (query) {
        ref
            .read(suggestionsNotifierProvider(ref.readConfigAuth).notifier)
            .getSuggestions(query);
      },
      extraHeaders: widget.extraHeaders,
      landingView:
          widget.landingViewBuilder?.call(_controller) ??
          DefaultMobileSearchLandingView(
            controller: _controller,
          ),
      itemBuilder: widget.itemBuilder,
      searchSuggestions: DefaultSearchSuggestions(
        multiSelectController: _searchModeController,
        config: ref.watchConfigAuth,
      ),
      resultHeader: ValueListenableBuilder(
        valueListenable: _controller.tagString,
        builder: (context, value, _) => ValueListenableBuilder(
          valueListenable: _postController,
          builder: (context, postController, child) => postController != null
              ? ResultHeaderFromController(
                  controller: postController,
                  onRefresh: null,
                  hasCount:
                      ref.watchConfigAuth.booruType.postCountMethod ==
                      PostCountMethod.search,
                )
              : const SizedBox.shrink(),
        ),
      ),
      searchRegion:
          widget.searchRegionBuilder?.call(
            _postController,
            _controller,
          ) ??
          DefaultSearchRegion(
            controller: _controller,
            initialQuery: widget.initialQuery,
            postController: _postController,
          ),
      onPostControllerCreated: (controller) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _postController.value = controller;
        });
      },
    );
  }
}

class DefaultMobileSearchLandingView extends StatelessWidget {
  const DefaultMobileSearchLandingView({
    super.key,
    this.notice,
    required this.controller,
  });

  final SearchPageController controller;
  final Widget? notice;

  @override
  Widget build(BuildContext context) {
    return SearchLandingView(
      child: DefaultSearchLandingChildren(
        notice: notice,
        children: [
          DefaultMobileQueryActionSection(controller: controller),
          DefaultMobileFavoriteTagsSection(controller: controller),
          DefaultMobileSearchHistorySection(controller: controller),
        ],
      ),
    );
  }
}

class DefaultMobileSearchHistorySection extends StatelessWidget {
  const DefaultMobileSearchHistorySection({
    super.key,
    required this.controller,
  });

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultSearchHistorySection(
      onHistoryTap: (value) {
        controller.tapHistoryTag(value);
      },
    );
  }
}

class DefaultMobileFavoriteTagsSection extends StatelessWidget {
  const DefaultMobileFavoriteTagsSection({
    super.key,
    required this.controller,
  });

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultFavoriteTagsSection(
      onTagTap: (value) {
        controller.tapFavTag(value);
      },
    );
  }
}

class DefaultMobileQueryActionSection extends StatelessWidget {
  const DefaultMobileQueryActionSection({
    super.key,
    required this.controller,
  });

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultQueryActionsSection(
      onTagAdded: (value) => controller.tagsController.addTag(
        TagSearchItem.raw(tag: value),
      ),
    );
  }
}

class DefaultSearchRegion extends ConsumerWidget {
  const DefaultSearchRegion({
    required this.controller,
    required this.postController,
    this.innerSearchButton,
    this.initialQuery,
    super.key,
  });

  final SearchPageController controller;
  final ValueNotifier<PostGridController?> postController;
  final String? initialQuery;
  final Widget? innerSearchButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoFocusSearchBar = ref.watch(
      settingsProvider.select((value) => value.autoFocusSearchBar),
    );
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return ValueListenableBuilder(
      valueListenable: postController,
      builder: (context, postControllerValue, _) {
        return RawSearchRegion(
          searchBarPosition: searchBarPosition,
          autoFocusSearchBar: autoFocusSearchBar,
          controller: controller,
          tagList: SelectedTagListWithData(
            controller: controller.tagsController,
            config: ref.watchConfig,
          ),
          innerSearchButton:
              innerSearchButton ??
              DefaultInnerSearchButton(
                controller: controller,
                postController: postControllerValue,
              ),
          initialQuery: initialQuery,
        );
      },
    );
  }
}

class DefaultInnerSearchButton extends StatelessWidget {
  const DefaultInnerSearchButton({
    required this.controller,
    this.postController,
    super.key,
    this.disableAnimation,
  });

  final SearchPageController controller;
  final PostGridController? postController;
  final bool? disableAnimation;

  @override
  Widget build(BuildContext context) {
    return MultiValueListenableBuilder2(
      first: controller.allowSearch,
      second: controller.didSearchOnce,
      builder: (context, allowSearch, searchOnce) {
        final searchButton = Padding(
          padding: const EdgeInsets.only(
            right: 8,
          ),
          child: SearchButton2(
            onTap: () {
              controller.search();
              postController?.refresh();
              controller.focus.unfocus();
            },
          ),
        );

        final disable = disableAnimation ?? false;

        if (disable) {
          return searchOnce
              ? searchButton
              : allowSearch
              ? searchButton
              : const SizedBox.shrink();
        }

        return searchOnce
            ? searchButton
            : AnimatedOpacity(
                opacity: allowSearch ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: allowSearch ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: searchButton,
                ),
              );
      },
    );
  }
}

class DefaultTrailingSearchButton extends StatelessWidget {
  const DefaultTrailingSearchButton({
    required this.controller,
    super.key,
  });

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.didSearchOnce,
      builder: (_, searchOnce, _) {
        return !searchOnce
            ? const SizedBox.shrink()
            : ValueListenableBuilder(
                valueListenable: controller.state,
                builder: (_, state, _) => state != SearchState.suggestions
                    ? AnimatedRotation(
                        duration: const Duration(milliseconds: 150),
                        turns: state == SearchState.options ? 0.13 : 0,
                        child: IconButton(
                          iconSize: 28,
                          onPressed: () {
                            if (state != SearchState.options) {
                              controller.changeState(SearchState.options);
                            } else {
                              controller.changeState(SearchState.initial);
                            }
                          },
                          icon: const Icon(Symbols.add),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
      },
    );
  }
}

class DefaultSearchSuggestions extends ConsumerWidget {
  const DefaultSearchSuggestions({
    required this.multiSelectController,
    required this.config,
    super.key,
  });

  final SelectionModeController multiSelectController;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return SearchRegionSafeArea(
      selectionModeController: multiSelectController,
      child: MultiValueListenableBuilder2(
        first: controller.state,
        second: controller.didSearchOnce,
        builder: (_, state, searchOnce) => state == SearchState.suggestions
            ? ColoredBox(
                color: colorScheme.surface,
                child: Column(
                  children: [
                    ref
                        .watch(analyticsProvider)
                        .maybeWhen(
                          data: (analytics) => SearchViewAnalyticsAnchor(
                            routeName: '/search_suggestions',
                            previousRoute: !searchOnce
                                ? ModalRoute.of(context)?.settings
                                : const RouteSettings(name: '/search_result'),
                            analytics: analytics,
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: controller.textController,
                        builder: (context, query, child) {
                          final suggestionTags = ref.watch(
                            suggestionProvider((config, query.text)),
                          );

                          return TagSuggestionItems(
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              top: 8,
                              bottom: 16,
                            ),
                            reverse:
                                searchBarPosition == SearchBarPosition.bottom,
                            config: config,
                            tags: suggestionTags,
                            currentQuery: query.text,
                            onItemTap: (tag) {
                              controller.tapTag(tag.value);
                            },
                            emptyBuilder: () => Center(
                              child: ColoredBox(
                                color: colorScheme.surface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
