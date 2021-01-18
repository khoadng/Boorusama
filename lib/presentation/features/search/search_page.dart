import 'package:boorusama/application/download/post_download_state_notifier.dart';
import 'package:boorusama/application/home/latest/latest_state_notifier.dart';
import 'package:boorusama/application/search/suggestions_state_notifier.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/presentation/features/search/tag_query.dart';
import 'package:boorusama/presentation/shared/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'tag_suggestion_items.dart';

final suggestionsStateNotifier =
    StateNotifierProvider<SuggestionsStateNotifier>(
        (ref) => SuggestionsStateNotifier(ref));

final postDownloadStateNotifierProvider =
    StateNotifierProvider<PostDownloadStateNotifier>(
        (ref) => PostDownloadStateNotifier(ref));

final postSearchStateNotifierProvider =
    StateNotifierProvider<LatestStateNotifier>(
        (ref) => LatestStateNotifier(ref));

class SearchPage extends SearchDelegate {
  List<Tag> _tags;
  TagQuery _tagQuery;
  List<Post> _posts;
  int _page = 1;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  SearchPage({
    TextStyle searchFieldStyle,
  }) : super(searchFieldStyle: searchFieldStyle) {
    _tags = List<Tag>();
    _posts = <Post>[];
    _tagQuery = TagQuery(
      onTagInputCompleted: () => _tags.clear(),
      onCleared: null,
    );

    _tagQuery.update(query);
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
    return ProviderListener<LatestState>(
      provider: postSearchStateNotifierProvider.state,
      onChange: (context, state) {
        state.maybeWhen(
            fetched: (posts) {
              if (posts.isEmpty) {
                _refreshController.loadNoData();
              } else {
                _refreshController.loadComplete();
                _refreshController.refreshCompleted();
                _posts.addAll(posts);
              }
            },
            orElse: () {});
      },
      child: Consumer(
        builder: (context, watch, child) {
          final state = watch(postSearchStateNotifierProvider.state);
          return state.when(
              initial: () => Center(child: CircularProgressIndicator()),
              refreshing: () => Center(child: CircularProgressIndicator()),
              loading: () => Center(child: CircularProgressIndicator()),
              fetched: (_) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => _downloadAllPosts(_posts, context),
                    heroTag: null,
                    child: Icon(Icons.download_sharp),
                  ),
                  body: SmartRefresher(
                    controller: _refreshController,
                    enablePullUp: true,
                    footer: const ClassicFooter(),
                    onLoading: () {
                      _page = _page + 1;
                      context
                          .read(postSearchStateNotifierProvider)
                          .getPosts(query, _page);
                    },
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Container(
                                padding: EdgeInsets.all(2.0),
                              ),
                            ],
                          ),
                        ),
                        SliverPostGrid(
                          posts: _posts,
                        ),
                      ],
                    ),
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
                    child: Text(I18n.of(context).searchNoResult),
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
      return Center(child: Text(I18n.of(context).searchEmpty));
    }
  }

  void _submit(BuildContext context) {
    showResults(context);
    context.read(postSearchStateNotifierProvider).getPosts(query, 1);
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
