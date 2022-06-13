// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import '../../shared/tag_suggestion_items.dart';
import 'services/query_processor.dart';

class SearchPage extends HookWidget {
  const SearchPage({
    Key? key,
    this.initialQuery = '',
  }) : super(key: key);

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    final queryEditingController = useTextEditingController
        .fromValue(TextEditingValue(text: initialQuery));
    final searchDisplayState = useState(SearchDisplayState.searchOptions());
    final suggestions = useState(<Tag>[]);

    final completedQueryItems = useState(<String>[]);
    final refreshController = useState(RefreshController());

    useEffect(() {
      ReadContext(context).read<SearchHistoryCubit>().getSearchHistory();
      return null;
    }, []);

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
      queryEditingController.text = '';
      completedQueryItems.value = LinkedHashSet<String>.from(
          [...completedQueryItems.value, ...tag.split(' ')]).toList();
    }

    void removeTag(String tag) {
      completedQueryItems.value = [...completedQueryItems.value..remove(tag)];
    }

    Future<void> onTextInputChanged(String text) async {
      if (text.trim().isEmpty) {
        // Make sure input is not empty
        return;
      }

      if (text.endsWith(' ')) {
        queryEditingController.text = '';
      }

      final lastTag = QueryProcessor().process(
          text, queryEditingController.text, completedQueryItems.value);

      final tags = await RepositoryProvider.of<ITagRepository>(context)
          .getTagsByNamePattern(lastTag, 1);
      suggestions.value = [...tags];
    }

    void onSearchClearButtonTap() {
      searchDisplayState.value.maybeWhen(
        orElse: () {
          queryEditingController.text = '';
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

      ReadContext(context)
          .read<SearchHistoryCubit>()
          .addHistory(completedQueryItems.value.join(' '));

      FocusScope.of(context).unfocus();
      searchDisplayState.value = SearchDisplayState.results();

      context
          .read<PostBloc>()
          .add(PostRefreshed(tag: completedQueryItems.value.join(' ')));
    }

    Widget _buildTags() {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        height: 50,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: completedQueryItems.value.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                padding: const EdgeInsets.all(4),
                labelPadding: const EdgeInsets.all(1),
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
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Scaffold(
        floatingActionButton: searchDisplayState.value.maybeWhen(
          results: () => const SizedBox.shrink(),
          orElse: () => FloatingActionButton(
            onPressed: onSearchButtonTap,
            heroTag: null,
            child: const Icon(Icons.search),
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
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackButtonTap,
            ),
            trailing: queryEditingController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onSearchClearButtonTap,
                  )
                : null,
            onChanged: onTextInputChanged,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (completedQueryItems.value.isNotEmpty) ...[
                _buildTags(),
                const Divider(
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
                        queryEditingController.text = '$searchOption:',
                    onHistoryTap: (history) =>
                        queryEditingController.text = history,
                  ),
                  suggestions: () => TagSuggestionItems(
                    tags: suggestions.value,
                    onItemTap: (tag) => addTag(tag.rawName),
                  ),
                  results: () {
                    return BlocBuilder<PostBloc, PostState>(
                      buildWhen: (previous, current) => !current.hasMore,
                      builder: (context, state) {
                        return InfiniteLoadList(
                          refreshController: refreshController.value,
                          enableLoadMore: state.hasMore,
                          onLoadMore: () => context.read<PostBloc>().add(
                              PostFetched(
                                  tags: completedQueryItems.value.join(' '))),
                          onRefresh: (controller) {
                            context.read<PostBloc>().add(PostRefreshed(
                                tag: completedQueryItems.value.join(' ')));
                            Future.delayed(const Duration(milliseconds: 500),
                                () => controller.refreshCompleted());
                          },
                          builder: (context, controller) => CustomScrollView(
                            controller: controller,
                            slivers: <Widget>[
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                sliver: BlocBuilder<PostBloc, PostState>(
                                  buildWhen: (previous, current) =>
                                      current.status != LoadStatus.loading,
                                  builder: (context, state) {
                                    if (state.status == LoadStatus.initial) {
                                      return const SliverPostGridPlaceHolder();
                                    } else if (state.status ==
                                        LoadStatus.success) {
                                      if (state.posts.isEmpty) {
                                        return const SliverToBoxAdapter(
                                            child:
                                                Center(child: Text('No data')));
                                      }
                                      return SliverPostGrid(
                                        posts: state.posts,
                                        scrollController: controller,
                                        onTap: (post, index) =>
                                            AppRouter.router.navigateTo(
                                          context,
                                          '/post/detail',
                                          routeSettings: RouteSettings(
                                            arguments: [
                                              state.posts,
                                              index,
                                              controller,
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (state.status ==
                                        LoadStatus.loading) {
                                      return const SliverToBoxAdapter(
                                        child: SizedBox.shrink(),
                                      );
                                    } else {
                                      return const SliverToBoxAdapter(
                                        child: Center(
                                          child: Text('Something went wrong'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              BlocBuilder<PostBloc, PostState>(
                                builder: (context, state) {
                                  if (state.status == LoadStatus.loading) {
                                    return const SliverPadding(
                                      padding:
                                          EdgeInsets.only(bottom: 20, top: 20),
                                      sliver: SliverToBoxAdapter(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SliverToBoxAdapter(
                                      child: SizedBox.shrink(),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  noResults: () => const EmptyResult(
                      text:
                          'We searched far and wide, but no results were found.'),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/search-file.json',
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/server-error.json',
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

abstract class SearchDisplayState extends Equatable {
  const SearchDisplayState();
  factory SearchDisplayState.results() => Results();
  factory SearchDisplayState.suggestions() => Suggestions();
  factory SearchDisplayState.searchOptions() => __SearchOptions();
  factory SearchDisplayState.noResults() => NoResults();
  factory SearchDisplayState.error(String message) => Error(message: message);
  TResult when<TResult extends Object>({
    required TResult Function()? results,
    required TResult Function()? suggestions,
    required TResult Function()? searchOptions,
    required TResult Function()? noResults,
    required TResult Function(String message)? error,
  });
  TResult maybeWhen<TResult extends Object>({
    TResult Function()? results,
    TResult Function()? suggestions,
    TResult Function()? searchOptions,
    TResult Function()? noResults,
    TResult Function(String message)? error,
    required TResult Function() orElse,
  });
}

class Results extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error,
      required TResult Function() orElse}) {
    if (results != null) {
      return results();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error}) {
    return results!();
  }

  @override
  List<Object> get props => ['results'];
}

class Suggestions extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error,
      required TResult Function() orElse}) {
    if (suggestions != null) {
      return suggestions();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error}) {
    return suggestions!();
  }

  @override
  List<Object> get props => ['suggestions'];
}

class __SearchOptions extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error,
      required TResult Function() orElse}) {
    if (searchOptions != null) {
      return searchOptions();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error}) {
    return searchOptions!();
  }

  @override
  List<Object> get props => ['searchOptions'];
}

class NoResults extends SearchDisplayState {
  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error,
      required TResult Function() orElse}) {
    if (noResults != null) {
      return noResults();
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error}) {
    return noResults!();
  }

  @override
  List<Object> get props => ['noResults'];
}

class Error extends SearchDisplayState {
  const Error({
    required this.message,
  });
  final String message;

  @override
  TResult maybeWhen<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error,
      required TResult Function() orElse}) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  TResult when<TResult extends Object>(
      {TResult Function()? results,
      TResult Function()? suggestions,
      TResult Function()? searchOptions,
      TResult Function()? noResults,
      TResult Function(String message)? error}) {
    return error!(message);
  }

  @override
  List<Object> get props => ['error', message];
}
