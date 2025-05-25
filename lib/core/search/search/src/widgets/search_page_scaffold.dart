import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../analytics.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config.dart';
import '../../../../configs/ref.dart';
import '../../../../posts/count/widgets.dart';
import '../../../../posts/listing/providers.dart';
import '../../../../posts/post/post.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../tags/configs/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../histories/providers.dart';
import '../../../selected_tags/providers.dart';
import '../../../suggestions/providers.dart';
import '../../../suggestions/widgets.dart';
import '../pages/search_page.dart';
import '../views/search_landing_view.dart';
import 'raw_search_page_scaffold.dart';
import 'search_app_bar.dart';
import 'search_button.dart';
import 'search_controller.dart';
import 'selected_tag_list_with_data.dart';

class SearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const SearchPageScaffold({
    required this.fetcher,
    required this.params,
    super.key,
    this.noticeBuilder,
    this.queryPattern,
    this.metatags,
    this.trending,
    this.extraHeaders,
    this.itemBuilder,
  });

  final SearchParams params;

  String? get initialQuery => params.initialQuery;
  int? get initialPage => params.initialPage;
  int? get initialScrollPosition => params.initialScrollPosition;

  final Widget Function(BuildContext context)? noticeBuilder;

  final List<Widget> Function(
    BuildContext context,
    PostGridController<T> postController,
  )? extraHeaders;

  final PostsOrErrorCore<T> Function(
    int page,
    SelectedTagController selectedTagController,
  ) fetcher;

  final Map<RegExp, TextStyle>? queryPattern;

  final IndexedSelectableSearchWidgetBuilder<T>? itemBuilder;

  final Widget? Function(BuildContext context, SearchPageController controller)?
      metatags;
  final Widget? Function(BuildContext context, SearchPageController controller)?
      trending;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  late final SelectedTagController _tagsController;
  late final SearchPageController _controller;
  final MultiSelectController _multiSelectController = MultiSelectController();
  PostGridController<T>? _postController;

  @override
  void initState() {
    super.initState();

    _tagsController = SelectedTagController.fromBooruBuilder(
      builder: ref.read(booruBuilderProvider(ref.readConfigAuth)),
      tagInfo: ref.read(tagInfoProvider),
    );

    _controller = SearchPageController(
      onSearch: () {
        ref
            .read(searchHistoryProvider.notifier)
            .addHistoryFromController(_tagsController);
      },
      queryPattern: widget.queryPattern,
      tagsController: _tagsController,
    );
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _controller.dispose();
    _multiSelectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawSearchPageScaffold(
      fetcher: widget.fetcher,
      params: widget.params,
      tagsController: _tagsController,
      controller: _controller,
      multiSelectController: _multiSelectController,
      onQueryChanged: (query) {
        ref
            .read(suggestionsNotifierProvider(ref.readConfigAuth).notifier)
            .getSuggestions(query);
      },
      noticeBuilder: widget.noticeBuilder,
      extraHeaders: widget.extraHeaders,
      queryPattern: widget.queryPattern,
      landingView: Consumer(
        builder: (context, ref, __) {
          final searchBarPosition = ref.watch(searchBarPositionProvider);

          return SearchLandingView(
            reverse: searchBarPosition == SearchBarPosition.bottom,
            onHistoryTap: (value) {
              _controller.tapHistoryTag(value);
            },
            onFavTagTap: (value) {
              _controller.tapFavTag(value);
            },
            onRawTagTap: (value) => _controller.tagsController.addTag(
              value,
              isRaw: true,
            ),
            metatags: widget.metatags?.call(context, _controller),
            trending: widget.trending?.call(context, _controller),
          );
        },
      ),
      itemBuilder: widget.itemBuilder,
      searchSuggestions: DefaultSearchSuggestions(
        multiSelectController: _multiSelectController,
        config: ref.watchConfigAuth,
      ),
      resultHeader: ValueListenableBuilder(
        valueListenable: _controller.tagString,
        builder: (context, value, _) => _postController != null
            ? ResultHeaderFromController(
                controller: _postController!,
                onRefresh: null,
                hasCount: ref.watchConfigAuth.booruType.postCountMethod ==
                    PostCountMethod.search,
              )
            : const SizedBox.shrink(),
      ),
      searchRegion: DefaultSearchRegion(
        controller: _controller,
        tagList: Consumer(
          builder: (context, ref, child) {
            return SelectedTagListWithData(
              controller: _tagsController,
              config: ref.watchConfig,
            );
          },
        ),
        onSearch: () {
          _controller.search();
          _postController?.refresh();
          _controller.focus.unfocus();
        },
        initialQuery: widget.initialQuery,
      ),
      onPostControllerCreated: (controller) {
        _postController = controller;
      },
    );
  }
}

class DefaultSearchRegion extends ConsumerWidget {
  const DefaultSearchRegion({
    required this.onSearch,
    required this.controller,
    required this.tagList,
    super.key,
    this.initialQuery,
    this.trailingSearchButton,
  });

  final VoidCallback onSearch;
  final String? initialQuery;
  final SearchPageController controller;
  final Widget tagList;
  final Widget? trailingSearchButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final parentRoute = ModalRoute.of(context);
    final autoFocusSearchBar = ref.watch(
      settingsProvider.select((value) => value.autoFocusSearchBar),
    );
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    final children = [
      SizedBox(
        height: kSearchBarHeight,
        child: MultiValueListenableBuilder2(
          first: controller.state,
          second: controller.didSearchOnce,
          builder: (_, state, searchOnce) {
            return SearchAppBar(
              onTapOutside: switch (searchBarPosition) {
                SearchBarPosition.top => null,
                // When search bar is at the bottom, keyboard will be kept open for better UX unless the app switches to results
                SearchBarPosition.bottom =>
                  searchOnce && state == SearchState.initial ? null : () {},
              },
              onSubmitted: (value) => controller.submit(value),
              trailingSearchButton: trailingSearchButton ??
                  DefaultTrailingSearchButton(controller: controller),
              innerSearchButton: _buildSearchButton(context),
              focusNode: controller.focus,
              autofocus: initialQuery == null ? autoFocusSearchBar : false,
              controller: controller.textController,
              leading: (parentRoute?.impliesAppBarDismissal ?? false)
                  ? const SearchAppBarBackButton()
                  : null,
            );
          },
        ),
      ),
      tagList,
    ];

    final region = ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: switch (searchBarPosition) {
          SearchBarPosition.top => children,
          SearchBarPosition.bottom => children.reversed.toList(),
        },
      ),
    );

    return searchBarPosition == SearchBarPosition.top
        ? region
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              region,
              const _SearchRegionBottomDisplacement(),
            ],
          );
  }

  Widget _buildSearchButton(BuildContext context) {
    final controller = InheritedSearchPageController.of(context);

    return MultiValueListenableBuilder2(
      first: controller.allowSearch,
      second: controller.didSearchOnce,
      builder: (context, allowSearch, searchOnce) {
        final searchButton = Padding(
          padding: const EdgeInsets.only(
            right: 8,
          ),
          child: SearchButton2(
            onTap: onSearch,
          ),
        );
        return searchOnce
            ? searchButton
            : AnimatedOpacity(
                opacity: allowSearch ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: allowSearch ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  alignment: Alignment.center,
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
      builder: (_, searchOnce, __) {
        return !searchOnce
            ? const SizedBox.shrink()
            : ValueListenableBuilder(
                valueListenable: controller.state,
                builder: (_, state, __) => state != SearchState.suggestions
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

class _SearchRegionBottomDisplacement extends StatelessWidget {
  const _SearchRegionBottomDisplacement();

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      height: max(viewInsets, viewPadding),
    );
  }
}

class DefaultSearchSuggestions extends ConsumerWidget {
  const DefaultSearchSuggestions({
    required this.multiSelectController,
    required this.config,
    super.key,
  });

  final MultiSelectController multiSelectController;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return SearchRegionSafeArea(
      multiSelectController: multiSelectController,
      child: MultiValueListenableBuilder2(
        first: controller.state,
        second: controller.didSearchOnce,
        builder: (_, state, searchOnce) => state == SearchState.suggestions
            ? ColoredBox(
                color: colorScheme.surface,
                child: Column(
                  children: [
                    ref.watch(analyticsProvider).maybeWhen(
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
                          final suggestionTags = ref
                              .watch(suggestionProvider((config, query.text)));

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
