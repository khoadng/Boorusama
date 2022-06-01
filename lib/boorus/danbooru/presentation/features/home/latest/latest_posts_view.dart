// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/home/lastest/tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/tag_chips_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';

class LatestView extends HookWidget {
  const LatestView({
    Key? key,
    required this.onMenuTap,
  }) : super(key: key);

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final posts = useState(<Post>[]);

    final selectedTag = useState("");

    final isMounted = useIsMounted();

    useEffect(() {
      ReadContext(context).read<SearchKeywordCubit>().getTags();
    }, []);

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
                orElse: () => Post.empty(),
              );
              return p.id == post.id;
            });
        }
        posts.value = [...posts.value, ...data];
      },
      onError: (message) {
        final snackbar = SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6.0,
          content: Text(message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      refreshBuilder: (page) => BuildContextX(context)
          .read(postProvider)
          .getPosts(selectedTag.value, page),
      loadMoreBuilder: (page) => BuildContextX(context)
          .read(postProvider)
          .getPosts(selectedTag.value, page),
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
            final selected = selectedTag.value == searches[index].keyword;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                selectedColor: Colors.white,
                selected: selected,
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    Widget mapStateToTagList(AsyncLoadState<Search> state) {
      switch (state.status) {
        case LoadStatus.success:
          return _buildTags(state.items);
        case LoadStatus.failure:
          return SizedBox.shrink();
        default:
          return TagChipsPlaceholder();
      }
    }

    final state = context.watch<SearchKeywordCubit>().state;

    return InfiniteLoadList(
      controller: infiniteListController.value,
      extendBody: true,
      headers: [
        SliverAppBar(
          toolbarHeight: kToolbarHeight * 1.2,
          title: SearchBar(
            enabled: false,
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => onMenuTap(),
            ),
            onTap: () => AppRouter.router.navigateTo(context, "/posts/search",
                routeSettings: RouteSettings(arguments: [''])),
          ),
          floating: true,
          snap: true,
          automaticallyImplyLeading: false,
        ),
        SliverToBoxAdapter(
          child: mapStateToTagList(state),
        ),
      ],
      posts: posts.value,
      child: isRefreshing.value
          ? SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              sliver: SliverPostGridPlaceHolder())
          : null,
    );
  }
}
