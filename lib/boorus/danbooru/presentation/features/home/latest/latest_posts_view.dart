// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/tag_chips_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';

final _popularSearchProvider =
    FutureProvider.autoDispose<List<Search>>((ref) async {
  final repo = ref.watch(popularSearchProvider);

  var searches = await repo.getSearchByDate(DateTime.now());
  if (searches.isEmpty) {
    searches =
        await repo.getSearchByDate(DateTime.now().subtract(Duration(days: 1)));
  }

  ref.maintainState = true;

  return searches;
});

class LatestView extends HookWidget {
  const LatestView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = useState(<Post>[]);

    final popularSearches = useProvider(_popularSearchProvider);
    final selectedTag = useState("");

    final isMounted = useIsMounted();

    final infiniteListController = useState(InfiniteLoadListController<Post>(
      onData: (data) {
        if (isMounted()) {
          posts.value = [...data];
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
      refreshBuilder: (page) =>
          context.read(postProvider).getPosts(selectedTag.value, page),
      loadMoreBuilder: (page) =>
          context.read(postProvider).getPosts(selectedTag.value, page),
    ));
    final isRefreshing = useRefreshingState(infiniteListController.value);
    useAutoRefresh(infiniteListController.value, [selectedTag.value]);

    Widget _buildTags(List<Search> searches) {
      return Container(
        margin: EdgeInsets.only(left: 8.0),
        height: 50,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: searches.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                selectedColor: Colors.white,
                selected: selectedTag.value == searches[index].keyword,
                onSelected: (selected) => selected
                    ? selectedTag.value = searches[index].keyword
                    : selectedTag.value = "",
                padding: EdgeInsets.all(4.0),
                labelPadding: EdgeInsets.all(1.0),
                visualDensity: VisualDensity.compact,
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85),
                  child: Text(
                    searches[index].keyword.pretty,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return InfiniteLoadList(
      controller: infiniteListController.value,
      extendBody: true,
      headers: [
        SliverAppBar(
          toolbarHeight: kToolbarHeight * 1.2,
          title: SearchBar(
            enabled: false,
            leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}
                // scaffoldKey.currentState.openDrawer(),
                ),
            onTap: () => AppRouter.router.navigateTo(context, "/posts/search",
                routeSettings: RouteSettings(arguments: [''])),
          ),
          floating: true,
          snap: true,
          automaticallyImplyLeading: false,
        ),
        SliverToBoxAdapter(
          child: popularSearches.maybeWhen(
            data: (searches) => _buildTags(searches),
            orElse: () => TagChipsPlaceholder(),
          ),
        ),
      ],
      posts: posts.value,
      child: isRefreshing.value
          ? SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              sliver: SliverPostGridPlaceHolder())
          : null,
    );
  }
}
