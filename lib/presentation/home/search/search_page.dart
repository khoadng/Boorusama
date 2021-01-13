import 'package:boorusama/application/download/post_download_state_notifier.dart';
import 'package:boorusama/application/home/browse_all/browse_all_state_notifier.dart';
import 'package:boorusama/application/search/bloc/suggestions_state_notifier.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/home/browse_all/browse_all_view.dart';
import 'package:boorusama/presentation/home/refreshable_list.dart';
import 'package:boorusama/presentation/home/tag_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'tag_suggestion_items.dart';

final suggestionsStateNotifier =
    StateNotifierProvider<SuggestionsStateNotifier>(
        (ref) => SuggestionsStateNotifier(ref));

class SearchPage extends SearchDelegate {
  List<Tag> _tags;
  TagQuery _tagQuery;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  SearchPage({
    TextStyle searchFieldStyle,
  }) : super(searchFieldStyle: searchFieldStyle) {
    _tags = List<Tag>();
    _tagQuery = TagQuery(
      onTagInputCompleted: () => _tags.clear(),
      onCleared: null,
    );

    if (query.isNotEmpty) {
      _tagQuery.update(query);
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          showSuggestions(context);
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ProviderListener<BrowseAllState>(
      provider: browseAllStateNotifier.state,
      onChange: (context, state) {
        state.maybeWhen(
            fetched: (posts, page, query) => _refreshController
              ..loadComplete()
              ..refreshCompleted(),
            orElse: () {});
      },
      child: Consumer(
        builder: (context, watch, child) {
          final state = watch(browseAllStateNotifier.state);
          return state.when(
              initial: () => Center(),
              loading: () => Center(child: CircularProgressIndicator()),
              fetched: (posts, page, query) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => _downloadAllPosts(posts, context),
                    heroTag: null,
                    child: Icon(Icons.download_sharp),
                  ),
                  body: RefreshableList(
                    posts: posts,
                    onLoadMore: () => context
                        .read(browseAllStateNotifier)
                        .getMorePosts(posts, query, page),
                    onRefresh: () =>
                        context.read(browseAllStateNotifier).refresh(),
                    refreshController: _refreshController,
                  ),
                );
              });
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _tagQuery.update(query);

    if (query.isNotEmpty) {
      Future.delayed(
          Duration.zero,
          () => context
              .read(suggestionsStateNotifier)
              .getSuggestions(_tagQuery.currentTag));

      return Consumer(
        builder: (context, watch, child) {
          final state = watch(suggestionsStateNotifier.state);
          return state.when(
              empty: () => Center(
                    child: Text("No result"),
                  ),
              loading: () => _SearchSuggestionsStack(
                    child: Center(child: CircularProgressIndicator()),
                    onSearch: () => _submit(context),
                  ),
              fetched: (tags) => _SearchSuggestionsStack(
                  child: TagSuggestionItems(
                      tags: tags, onItemTap: (tag) => _onTagItemSelected(tag)),
                  onSearch: () => _submit(context)),
              error: (name, message) => Center(
                    child: Text(message),
                  ));
        },
      );
    } else {
      return Center(child: Text("Such empty"));
    }
  }

  void _submit(BuildContext context) {
    showResults(context);
    context.read(browseAllStateNotifier).getPosts(query, 1);
  }

  void _onTagItemSelected(String tag) {
    _tagQuery.add(tag);
    query = _tagQuery.currentQuery;
    setCursorPosition(query.length);
  }

  void _downloadAllPosts(List<Post> posts, BuildContext context) {
    posts.forEach((post) =>
        context.read(postDownloadStateNotifierProvider).download(post));
  }
}

class _SearchSuggestionsStack extends StatelessWidget {
  const _SearchSuggestionsStack({
    Key key,
    @required this.child,
    @required this.onSearch,
  }) : super(key: key);

  final Widget child;
  final Function onSearch;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      child,
      Positioned(
        bottom: 30.0,
        right: 30.0,
        child: FloatingActionButton(
          onPressed: () => onSearch(),
          child: Icon(Icons.search),
        ),
      )
    ]);
  }
}
