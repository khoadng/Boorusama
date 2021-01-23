import 'package:boorusama/boorus/danbooru/application/download/post_download_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/search/query_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/search/search_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/search/suggestions_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'tag_suggestion_items.dart';

final _postDownloadStateNotifierProvider =
    StateNotifierProvider<PostDownloadStateNotifier>(
        (ref) => PostDownloadStateNotifier(ref));

final _displayState = Provider<SearchDisplayState>(
    (ref) => ref.watch(searchStateNotifierProvider.state).displayState);
final _searchDisplayProvider = Provider<SearchDisplayState>((ref) {
  final status = ref.watch(_displayState);
  print("Display status: $status");
  return status;
});

final _monitoringState = Provider<SearchMonitoringState>(
    (ref) => ref.watch(searchStateNotifierProvider.state).monitoringState);
final _searchMonitoringProvider = Provider<SearchMonitoringState>((ref) {
  final status = ref.watch(_monitoringState);
  print("Search monitoring status: $status");
  return status;
});

final _posts = Provider<List<Post>>(
    (ref) => ref.watch(searchStateNotifierProvider.state).posts);
final _postProvider = Provider<List<Post>>((ref) {
  final posts = ref.watch(_posts);
  return posts;
});

final _query = Provider<String>(
    (ref) => ref.watch(queryStateNotifierProvider.state).query);
final _queryProvider = Provider<String>((ref) {
  final query = ref.watch(_query);
  print("Search query: $query");
  return query;
});

final _tags = Provider<List<Tag>>(
    (ref) => ref.watch(suggestionsStateNotifier.state).tags);
final _tagProvider = Provider<List<Tag>>((ref) {
  final tags = ref.watch(_tags);
  return tags;
});

final _suggestionsMonitoring = Provider<SuggestionsMonitoringState>((ref) =>
    ref.watch(suggestionsStateNotifier.state).suggestionsMonitoringState);
final _suggestionsMonitoringStateProvider =
    Provider<SuggestionsMonitoringState>((ref) {
  final status = ref.watch(_suggestionsMonitoring);
  print("Tag suggestion monitoring status: $status");
  return status;
});

class SearchPage extends HookWidget {
  const SearchPage({Key key, this.initialQuery}) : super(key: key);

  final String initialQuery;

  void _onTagItemTapped(BuildContext context, String tag) =>
      context.read(queryStateNotifierProvider).add(tag);

  void _onClearQueryButtonPressed(BuildContext context) {
    context.read(searchStateNotifierProvider).clear();
    context.read(suggestionsStateNotifier).clear();
    context.read(queryStateNotifierProvider).clear();
  }

  void _onBackIconPressed(BuildContext context) {
    context.read(searchStateNotifierProvider).clear();
    context.read(suggestionsStateNotifier).clear();
    context.read(queryStateNotifierProvider).clear();
    Navigator.of(context).pop();
  }

  void _onDownloadButtonPressed(List<Post> posts, BuildContext context) {
    return posts.forEach((post) =>
        context.read(_postDownloadStateNotifierProvider).download(post));
  }

  void _onSearchButtonPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read(searchStateNotifierProvider).search();
  }

  void _onQueryUpdated(BuildContext context, String value) {
    context.read(queryStateNotifierProvider).update(value);
  }

  void _onLoadCompleted(ValueNotifier<RefreshController> refreshController) {
    refreshController.value.refreshCompleted();
    return refreshController.value.loadComplete();
  }

  void _onListLoading(BuildContext context) =>
      context.read(searchStateNotifierProvider).getMoreResult();

  @override
  Widget build(BuildContext context) {
    //TODO: MEMORY LEAK HERE, CUSTOM HOOK NEEDED
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final scrollController = useScrollController();
    final queryEditingController = useTextEditingController();

    final gridKey = useState(GlobalKey());

    final searchDisplayState = useProvider(_searchDisplayProvider);
    final searchMonitoringState = useProvider(_searchMonitoringProvider);
    final posts = useProvider(_postProvider);
    final query = useProvider(_queryProvider);

    final suggestionsMonitoringState =
        useProvider(_suggestionsMonitoringStateProvider);
    final tags = useProvider(_tagProvider);

    useEffect(() {
      queryEditingController.text = query;
      queryEditingController.selection =
          TextSelection.fromPosition(TextPosition(offset: query.length));
      return () => {};
    }, [query]);

    return ProviderListener<SearchState>(
      provider: searchStateNotifierProvider.state,
      onChange: (context, state) => state.monitoringState.when(
        none: () => true,
        inProgress: (loadingType) => loadingType,
        completed: () => _onLoadCompleted(refreshController),
      ),
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: searchDisplayState.when(
            suggestions: () => FloatingActionButton(
              onPressed: () => _onSearchButtonPressed(context),
              heroTag: null,
              child: Icon(Icons.search),
            ),
            results: () => FloatingActionButton(
              onPressed: () => _onDownloadButtonPressed(posts, context),
              heroTag: null,
              child: Icon(Icons.download_sharp),
            ),
          ),
          appBar: AppBar(
            elevation: 0,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: SearchBar(
              autofocus: true,
              queryEditingController: queryEditingController,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _onBackIconPressed(context),
              ),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => _onClearQueryButtonPressed(context),
              ),
              onChanged: (value) => _onQueryUpdated(context, value),
            ),
          ),
          body: searchDisplayState.when(
            suggestions: () => suggestionsMonitoringState.when(
              none: () => Center(child: Text(I18n.of(context).searchNoResult)),
              inProgress: () => Padding(
                padding: EdgeInsets.only(top: 8),
                child: TagSuggestionItems(tags: tags, onItemTap: (tag) {}),
              ),
              completed: () => Padding(
                padding: EdgeInsets.only(top: 8),
                child: TagSuggestionItems(
                    tags: tags,
                    onItemTap: (tag) => _onTagItemTapped(context, tag)),
              ),
              error: () => Center(
                child: Text("Something went wrong"),
              ),
            ),
            results: () => searchMonitoringState.when(
              none: () => CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.all(6.0),
                    sliver: SliverPostGridPlaceHolder(
                        scrollController: scrollController),
                  )
                ],
              ),
              inProgress: (loadingType) => loadingType == LoadingType.refresh
                  ? CustomScrollView(
                      slivers: <Widget>[
                        SliverPadding(
                          padding: EdgeInsets.all(6.0),
                          sliver: SliverPostGridPlaceHolder(
                              scrollController: scrollController),
                        )
                      ],
                    )
                  : CustomScrollView(
                      slivers: <Widget>[
                        SliverPadding(
                          padding: EdgeInsets.all(6.0),
                          sliver: SliverPostGrid(
                            key: gridKey.value,
                            posts: posts,
                            scrollController: scrollController,
                          ),
                        )
                      ],
                    ),
              completed: () => SmartRefresher(
                controller: refreshController.value,
                enablePullUp: true,
                enablePullDown: false,
                footer: const ClassicFooter(),
                onLoading: () => _onListLoading(context),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.all(6.0),
                      sliver: SliverPostGrid(
                        key: gridKey.value,
                        posts: posts,
                        scrollController: scrollController,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
