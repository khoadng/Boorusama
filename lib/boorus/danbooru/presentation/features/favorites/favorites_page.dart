// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/core/application/list_item_status.dart';

final _posts = Provider<List<Post>>(
    (ref) => ref.watch(favoritesStateNotifierProvider.state).posts.items);
final _postProvider = Provider<List<Post>>((ref) {
  return ref.watch(_posts);
});

final _postsState = Provider<ListItemStatus<Post>>((ref) {
  return ref.watch(favoritesStateNotifierProvider.state).posts.status;
});
final _postsStateProvider = Provider<ListItemStatus<Post>>((ref) {
  return ref.watch(_postsState);
});

class FavoritesPage extends HookWidget {
  const FavoritesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController = useState(RefreshController());
    final posts = useProvider(_postProvider);
    final postsState = useProvider(_postsStateProvider);
    final scrollController = useState(AutoScrollController());
    final gridKey = useState(GlobalKey());

    useEffect(() {
      return () => scrollController.value.dispose;
    }, []);

    return postsState.maybeWhen(
      refreshing: () => CustomScrollView(
        controller: scrollController.value,
        shrinkWrap: true,
        slivers: [
          SliverPostGridPlaceHolder(),
        ],
      ),
      orElse: () => ProviderListener(
        provider: favoritesStateNotifierProvider,
        onChange: (context, state) {
          state.maybeWhen(
            fetched: () {
              refreshController.value.loadComplete();
              refreshController.value.refreshCompleted();
            },
            error: () => Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text("Something went wrong"))),
            orElse: () {},
          );
        },
        child: InfiniteLoadList(
          onRefresh: () =>
              context.read(favoritesStateNotifierProvider).refresh(),
          onLoadMore: () =>
              context.read(favoritesStateNotifierProvider).getMorePosts(),
          onItemChanged: (index) {
            if (index > posts.length * 0.8) {
              context.read(favoritesStateNotifierProvider).getMorePosts();
            }
          },
          scrollController: scrollController.value,
          gridKey: gridKey.value,
          posts: posts,
          refreshController: refreshController.value,
        ),
      ),
    );
  }
}
