// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/local/repositories/search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';
import '../../shared/tag_suggestion_items.dart';
import 'services/query_processor.dart';

part 'search_page.freezed.dart';

class SearchPage extends HookWidget {
  const SearchPage({Key key, this.initialQuery = ''}) : super(key: key);

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    final queryEditingController = useTextEditingController();
    final searchDisplayState = useState(SearchDisplayState.searchOptions());
    final posts = useState(<Post>[]);
    final query = useState(initialQuery);
    final suggestions = useState(<Tag>[]);

    final completedQueryItems = useState(<String>[]);

    final isMounted = useIsMounted();

    final infiniteListController = useState(InfiniteLoadListController<Post>(
      onData: (data) {
        if (isMounted()) {
          posts.value = [...data];
          if (data.isEmpty &&
              searchDisplayState.value == SearchDisplayState.results()) {
            searchDisplayState.value = SearchDisplayState.noResults();
          }
        }
      },
      onMoreData: (data, page) {
        if (page > 1) {
          // Dedupe
          data
            ..removeWhere((post) {
              final p = posts.value.firstWhere(
                (sPost) => sPost.id == post.id,
                orElse: () => null,
              );
              return p?.id == post.id;
            });
        }
        posts.value = [...posts.value, ...data];
      },
      onError: (message) {
        if (searchDisplayState.value == SearchDisplayState.results()) {
          searchDisplayState.value = SearchDisplayState.error(message);
        }
      },
      refreshBuilder: (page) {
        return context
            .read(postProvider)
            .getPosts(completedQueryItems.value.join(' '), page);
      },
      loadMoreBuilder: (page) {
        return context
            .read(postProvider)
            .getPosts(completedQueryItems.value.join(' '), page);
      },
    ));

    final isRefreshing = useRefreshingState(infiniteListController.value);
    useAutoRefresh(infiniteListController.value, [completedQueryItems.value],
        refreshWhen: () =>
            completedQueryItems.value.isNotEmpty && query.value.isEmpty);

    useEffect(() {
      queryEditingController.addListener(() {
        if (searchDisplayState.value != SearchDisplayState.results()) {
          if (queryEditingController.text.isEmpty) {
            searchDisplayState.value = SearchDisplayState.searchOptions();
          } else {
            searchDisplayState.value = SearchDisplayState.suggestions();
          }
        }
      });
      return null;
    }, [queryEditingController]);

    useEffect(() {
      if (query.value.isNotEmpty) {
        searchDisplayState.value = SearchDisplayState.suggestions();
      }

      queryEditingController.text = query.value;
      queryEditingController.selection =
          TextSelection.fromPosition(TextPosition(offset: query.value.length));
      return () => {};
    }, [query.value]);

    useEffect(() {
      void switchToSearchOptionsView() {
        if (completedQueryItems.value.isEmpty) {
          searchDisplayState.value = SearchDisplayState.searchOptions();
        }
      }

      searchDisplayState.value.when(
          results: () => switchToSearchOptionsView(),
          suggestions: () {},
          searchOptions: () {},
          noResults: () => switchToSearchOptionsView(),
          error: (message) {
            switchToSearchOptionsView();
          });

      return null;
    }, [completedQueryItems.value]);

    void addTag(String tag) {
      query.value = "";
      completedQueryItems.value =
          LinkedHashSet<String>.from([...completedQueryItems.value, tag])
              .toList();
    }

    void removeTag(String tag) {
      completedQueryItems.value = [...completedQueryItems.value..remove(tag)];
    }

    void onTextInputChanged(String text) async {
      if (text.trim().isEmpty) {
        // Make sure input is not empty
        return;
      }

      query.value = context
          .read(queryProcessorProvider)
          .process(text, query.value, completedQueryItems.value);

      //TODO: should use completed query instead of query???
      final tags =
          await context.read(tagProvider).getTagsByNamePattern(query.value, 1);
      suggestions.value = [...tags];
    }

    void onSearchClearButtonTap() {
      searchDisplayState.value.maybeWhen(
        orElse: () => query.value = "",
        results: () {
          searchDisplayState.value = SearchDisplayState.searchOptions();

          return null;
        },
      );
    }

    void onBackButtonTap() {
      void clear() => completedQueryItems.value = [];
      void pop() => Navigator.of(context).pop();

      searchDisplayState.value.when(
        results: () => clear(),
        suggestions: () => pop(),
        searchOptions: () => pop(),
        noResults: () => clear(),
        error: (e) => clear(),
      );
    }

    void onSearchButtonTap() {
      if (query.value.isNotEmpty) {
        addTag(query.value);
      }

      context
          .read(searchHistoryProvider)
          .addHistory(completedQueryItems.value.join(' '));

      FocusScope.of(context).unfocus();
      searchDisplayState.value = SearchDisplayState.results();
      infiniteListController.value.refresh();
    }

    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Scaffold(
          floatingActionButton: searchDisplayState.value.maybeWhen(
            results: () => SizedBox.shrink(),
            orElse: () => FloatingActionButton(
              onPressed: () => onSearchButtonTap(),
              heroTag: null,
              child: Icon(Icons.search),
            ),
          ),
          appBar: AppBar(
            toolbarHeight: kToolbarHeight * 1.2,
            elevation: 0,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: SearchBar(
              autofocus: true,
              queryEditingController: queryEditingController,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => onBackButtonTap(),
              ),
              trailing: query.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => onSearchClearButtonTap(),
                    )
                  : null,
              onChanged: (value) => onTextInputChanged(value),
            ),
          ),
          body: Column(
            children: [
              if (completedQueryItems.value.length > 0) ...[
                Tags(
                  heightHorizontalScroll: 30,
                  horizontalScroll: true,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  itemCount: completedQueryItems.value.length,
                  itemBuilder: (index) => ItemTags(
                    index: index,
                    title:
                        completedQueryItems.value[index].replaceAll('_', ' '),
                    pressEnabled: false,
                    removeButton: ItemTagsRemoveButton(onRemoved: () {
                      removeTag(completedQueryItems.value[index]);
                      return true;
                    }),
                  ),
                ),
                Divider(
                  height: 15,
                  thickness: 3,
                  indent: 10,
                  endIndent: 10,
                ),
              ],
              Expanded(
                child: searchDisplayState.value.when(
                  searchOptions: () => SearchOptions(
                    onOptionTap: (searchOption) =>
                        query.value = "$searchOption:",
                    onHistoryTap: (history) => query.value = history,
                  ),
                  suggestions: () => TagSuggestionItems(
                    tags: suggestions.value,
                    onItemTap: (tag) => addTag(tag.rawName),
                  ),
                  results: () {
                    return InfiniteLoadList(
                      controller: infiniteListController.value,
                      posts: posts.value,
                      child: isRefreshing.value
                          ? SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              sliver: SliverPostGridPlaceHolder())
                          : null,
                    );
                  },
                  noResults: () => EmptyResult(
                      text:
                          "We searched far and wide, but no results were found."),
                  error: (message) {
                    return ErrorResult(text: message);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyResult extends StatelessWidget {
  const EmptyResult({
    Key key,
    @required this.text,
    this.icon,
  }) : super(key: key);

  final String text;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Lottie.asset(
              "assets/animations/search-file.json",
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorResult extends StatelessWidget {
  const ErrorResult({
    Key key,
    @required this.text,
    this.icon,
  }) : super(key: key);

  final String text;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Lottie.asset(
              "assets/animations/server-error.json",
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

@freezed
abstract class SearchDisplayState with _$SearchDisplayState {
  const factory SearchDisplayState.results() = _Results;
  const factory SearchDisplayState.suggestions() = _Suggestions;
  const factory SearchDisplayState.searchOptions() = _SearchOptions;
  const factory SearchDisplayState.noResults() = _NoResults;
  const factory SearchDisplayState.error(String message) = _Error;
}
