import 'package:boorusama/boorus/danbooru/application/download/post_download_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/home/latest/latest_posts_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/search/suggestions_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'tag_query.dart';
import 'tag_suggestion_items.dart';

final postDownloadStateNotifierProvider =
    StateNotifierProvider<PostDownloadStateNotifier>(
        (ref) => PostDownloadStateNotifier(ref));

final postSearchStateNotifierProvider =
    StateNotifierProvider<LatestStateNotifier>(
        (ref) => LatestStateNotifier(ref));

final suggestionsStateNotifier =
    StateNotifierProvider<SuggestionsStateNotifier>(
        (ref) => SuggestionsStateNotifier(ref));

final searchPageStateProvider = StateProvider<SearchPageState>((ref) {
  return SearchPageState.suggestion;
});

enum SearchPageState {
  suggestion,
  result,
}

class SearchPage extends HookWidget {
  const SearchPage({Key key, this.initialQuery}) : super(key: key);

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    //TODO: MEMORY LEAK HERE, CUSTOM HOOK NEEDED
    final searchBarController = useState(SearchBarController());
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final suggestions = useProvider(suggestionsStateNotifier.state);
    final tags = useState(List<Tag>());
    final tagQuery = useState(TagQuery(
      onTagInputCompleted: () => tags.value.clear(),
      onCleared: null,
    ));
    final gridKey = useState(GlobalKey());
    final searchPageState = useProvider(searchPageStateProvider);

    useEffect(() {
      Future.microtask(
          () => searchPageState.state = SearchPageState.suggestion);
      return () => {};
    }, []);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: SearchBar(
            autofocus: true,
            initialQuery: initialQuery,
            controller: searchBarController.value,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                searchPageState.state = SearchPageState.suggestion;
                tagQuery.value.update("");
                searchBarController.value.query = "";
                Navigator.of(context).pop();
              },
            ),
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                searchPageState.state = SearchPageState.suggestion;
                tagQuery.value.update("");
                searchBarController.value.query = "";
              },
            ),
            onChanged: (value) {
              tagQuery.value.update(searchBarController.value.query);

              if (searchBarController.value.query.isNotEmpty) {
                context.read(suggestionsStateNotifier).getSuggestions(value);
              }
            },
          ),
        ),
        body: searchPageState.state == SearchPageState.suggestion
            ? _buildSuggestions(
                context,
                searchBarController.value.query,
                tagQuery.value,
                searchBarController.value,
                suggestions,
                searchPageState)
            : Consumer(
                builder: (context, watch, child) {
                  final state = watch(postSearchStateNotifierProvider.state);

                  if (!state.isLoadingMore)
                    refreshController.value.loadComplete();
                  if (!state.isRefreshing)
                    refreshController.value.refreshCompleted();

                  return Scaffold(
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => state.posts.forEach((post) => context
                          .read(postDownloadStateNotifierProvider)
                          .download(post)),
                      heroTag: null,
                      child: Icon(Icons.download_sharp),
                    ),
                    body: SmartRefresher(
                      controller: refreshController.value,
                      enablePullUp: true,
                      enablePullDown: false,
                      footer: const ClassicFooter(),
                      onLoading: () => context
                          .read(postSearchStateNotifierProvider)
                          .getMore(),
                      child: CustomScrollView(
                        slivers: <Widget>[
                          SliverPadding(
                            padding: EdgeInsets.all(6.0),
                            sliver: state.isRefreshing
                                ? SliverPostGridPlaceHolder()
                                : SliverPostGrid(
                                    key: gridKey.value,
                                    posts: state.posts,
                                  ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSuggestions(
      BuildContext context,
      String query,
      TagQuery tagQuery,
      SearchBarController searchBarController,
      SuggestionsState suggestions,
      StateController<SearchPageState> searchPageState) {
    return query.isNotEmpty
        ? suggestions.when(
            empty: () => Center(child: Text(I18n.of(context).searchNoResult)),
            loading: () => Center(),
            fetched: (tags) => Padding(
              padding: EdgeInsets.only(top: 8),
              child: _SearchSuggestionsStack(
                  child: TagSuggestionItems(
                      tags: tags,
                      onItemTap: (tag) {
                        tagQuery.add(tag);
                        searchBarController.query = tagQuery.currentQuery;
                      }),
                  onSearch: () {
                    context
                        .read(postSearchStateNotifierProvider)
                        .refresh(searchBarController.query);
                    searchPageState.state = SearchPageState.result;
                    FocusScope.of(context).unfocus();
                  }),
            ),
            error: (name, message) => Center(
              child: Text(message),
            ),
          )
        : Center(child: Text(I18n.of(context).searchNoResult));
  }

  // void _downloadAllPosts(List<Post> posts, BuildContext context) {
  //   posts.forEach((post) =>
  //       context.read(postDownloadStateNotifierProvider).download(post));
  // }
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
