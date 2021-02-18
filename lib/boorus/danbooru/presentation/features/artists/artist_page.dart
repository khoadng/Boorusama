// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';

class ArtistPage extends HookWidget {
  const ArtistPage({
    Key key,
    @required this.referencePost,
  }) : super(key: key);

  final Post referencePost;

  @override
  Widget build(BuildContext context) {
    final posts = useState(<Post>[]);
    final artistName = useState(referencePost.tagStringArtist.split(' ').first);

    final isRefreshing = useState(false);

    final infiniteListController = useState(InfiniteLoadListController<Post>(
      onData: (data) {
        isRefreshing.value = false;
        posts.value = [...data];
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
          context.read(postProvider).getPosts(artistName.value, page),
      loadMoreBuilder: (page) =>
          context.read(postProvider).getPosts(artistName.value, page),
    ));

    final gridKey = useState(GlobalKey());

    void loadMoreIfNeeded(int index) {
      if (index > posts.value.length * 0.8) {
        infiniteListController.value.loadMore();
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        isRefreshing.value = true;
        infiniteListController.value.refresh();
      });

      return null;
    }, [artistName.value]);

    final height = MediaQuery.of(context).size.height - 24;
    return SlidingUpPanel(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      maxHeight: height,
      minHeight: height * 0.6,
      panelBuilder: (scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 32),
          child: InfiniteLoadList(
            scrollController: scrollController,
            enableRefresh: false,
            controller: infiniteListController.value,
            posts: posts.value,
            gridKey: gridKey.value,
            onItemChanged: (index) => loadMoreIfNeeded(index),
            child: isRefreshing.value
                ? SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    sliver: SliverPostGridPlaceHolder())
                : null,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: referencePost.normalImageUri.toString(),
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black.withOpacity(0.6)],
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.6),
            child: Text(
              artistName.value.pretty,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontWeight: FontWeight.w900),
            ),
          )
        ],
      ),
    );
  }
}
