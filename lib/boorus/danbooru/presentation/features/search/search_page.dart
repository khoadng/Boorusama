// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class SearchPage extends HookWidget {
  const SearchPage({Key? key, this.initialQuery = ''}) : super(key: key);

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    final queryEditingController = useTextEditingController
        .fromValue(TextEditingValue(text: initialQuery));
    final searchDisplayState = useState(SearchDisplayState.searchOptions());
    final posts = useState(<Post>[]);
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
                orElse: () => Post.empty(),
              );
              return p.id == post.id;
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
            completedQueryItems.value.isNotEmpty &&
            queryEditingController.text.isEmpty);

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
      if (queryEditingController.text.isNotEmpty) {
        searchDisplayState.value = SearchDisplayState.suggestions();
      }

      queryEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: queryEditingController.text.length));
      return () => {};
    }, [queryEditingController.text]);

    useEffect(() {
      void switchToSearchOptionsView() {
        if (completedQueryItems.value.isEmpty) {
          searchDisplayState.value = SearchDisplayState.searchOptions();
        }
      }

      searchDisplayState.value.when(results: () {
        switchToSearchOptionsView();
        return Null;
      }, suggestions: () {
        return Null;
      }, searchOptions: () {
        return Null;
      }, noResults: () {
        switchToSearchOptionsView();
        return Null;
      }, error: (message) {
        switchToSearchOptionsView();
        return Null;
      });

      return null;
    }, [completedQueryItems.value]);

    void addTag(String tag) {
      queryEditingController.text = "";
      completedQueryItems.value = LinkedHashSet<String>.from(
          [...completedQueryItems.value, ...tag.split(' ')]).toList();
    }

    void removeTag(String tag) {
      completedQueryItems.value = [...completedQueryItems.value..remove(tag)];
    }

    void onTextInputChanged(String text) async {
      if (text.trim().isEmpty) {
        // Make sure input is not empty
        return;
      }

      if (text.endsWith(' ')) {
        queryEditingController.text = '';
      }

      final lastTag = context.read(queryProcessorProvider).process(
          text, queryEditingController.text, completedQueryItems.value);

      final tags =
          await context.read(tagProvider).getTagsByNamePattern(lastTag, 1);
      suggestions.value = [...tags];
    }

    void onSearchClearButtonTap() {
      searchDisplayState.value.maybeWhen(
        orElse: () {
          queryEditingController.text = "";
          return Null;
        },
        results: () {
          searchDisplayState.value = SearchDisplayState.searchOptions();

          return Null;
        },
      );
    }

    void onBackButtonTap() {
      void clear() => completedQueryItems.value = [];
      void pop() => Navigator.of(context).pop();

      searchDisplayState.value.when(
        results: () {
          clear();
          return Null;
        },
        suggestions: () {
          pop();
          return Null;
        },
        searchOptions: () {
          pop();
          return Null;
        },
        noResults: () {
          clear();
          return Null;
        },
        error: (e) {
          clear();
          return Null;
        },
      );
    }

    void onSearchButtonTap() {
      if (queryEditingController.text.isNotEmpty) {
        addTag(queryEditingController.text);
      }

      context
          .read(searchHistoryProvider)
          .addHistory(completedQueryItems.value.join(' '));

      FocusScope.of(context).unfocus();
      searchDisplayState.value = SearchDisplayState.results();
      infiniteListController.value.refresh();
    }

    Widget _buildTags() {
      return Container(
        margin: const EdgeInsets.only(left: 8.0),
        height: 50,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: completedQueryItems.value.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(
                padding: const EdgeInsets.all(4.0),
                labelPadding: const EdgeInsets.all(1.0),
                visualDensity: VisualDensity.compact,
                deleteIcon: const Icon(
                  FontAwesomeIcons.xmark,
                  color: Colors.red,
                  size: 15,
                ),
                onDeleted: () => removeTag(completedQueryItems.value[index]),
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85),
                  child: Text(
                    completedQueryItems.value[index].replaceAll('_', ' '),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return ClipRRect(
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
            trailing: queryEditingController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => onSearchClearButtonTap(),
                  )
                : null,
            onChanged: (value) => onTextInputChanged(value),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (completedQueryItems.value.length > 0) ...[
                _buildTags(),
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
                        queryEditingController.text = "$searchOption:",
                    onHistoryTap: (history) =>
                        queryEditingController.text = history,
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
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
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
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

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
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

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

abstract class SearchDisplayState extends Equatable {
  SearchDisplayState();
  factory SearchDisplayState.results() => Results();
  factory SearchDisplayState.suggestions() => Suggestions();
  factory SearchDisplayState.searchOptions() => __SearchOptions();
  factory SearchDisplayState.noResults() => NoResults();
  factory SearchDisplayState.error(String message) => Error(message: message);
  TResult when<TResult extends Object>({
    required TResult results()?,
    required TResult suggestions()?,
    required TResult searchOptions()?,
    required TResult noResults()?,
    required TResult error(String message)?,
  });
  TResult maybeWhen<TResult extends Object>({
    TResult results()?,
    TResult suggestions()?,
    TResult searchOptions()?,
    TResult noResults()?,
    TResult error(String message)?,
    required TResult orElse(),
  });
}

class Results extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?,
      required TResult orElse()}) {
    if (results != null) {
      return results();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?}) {
    return results!();
  }

  @override
  List<Object> get props => ["results"];
}

class Suggestions extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?,
      required TResult orElse()}) {
    if (suggestions != null) {
      return suggestions();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?}) {
    return suggestions!();
  }

  @override
  List<Object> get props => ["suggestions"];
}

class __SearchOptions extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?,
      required TResult orElse()}) {
    if (searchOptions != null) {
      return searchOptions();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?}) {
    return searchOptions!();
  }

  @override
  List<Object> get props => ["searchOptions"];
}

class NoResults extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?,
      required TResult orElse()}) {
    if (noResults != null) {
      return noResults();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?}) {
    return noResults!();
  }

  @override
  List<Object> get props => ["noResults"];
}

class Error extends SearchDisplayState {
  Error({
    required this.message,
  });
  final String message;

  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?,
      required TResult orElse()}) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult results()?,
      TResult suggestions()?,
      TResult searchOptions()?,
      TResult noResults()?,
      TResult error(String message)?}) {
    return error!(message);
  }

  @override
  List<Object> get props => ["error", message];
}
