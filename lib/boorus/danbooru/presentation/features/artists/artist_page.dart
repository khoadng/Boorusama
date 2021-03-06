// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artist.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/artists/artist_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';

final _artistInfoProvider =
    FutureProvider.autoDispose.family<Artist, String>((ref, name) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(artistProvider);
  final artist = await repo.getArtist(name, cancelToken: cancelToken);

  ref.maintainState = true;

  return artist;
});

class ArtistPage extends HookWidget {
  const ArtistPage({
    Key key,
    @required this.artistName,
    @required this.backgroundImageUrl,
  }) : super(key: key);

  final String artistName;
  final String backgroundImageUrl;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - 24;
    final posts = useState(<Post>[]);
    final artistInfo = useProvider(_artistInfoProvider(artistName));
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
          context.read(postProvider).getPosts(artistName, page),
      loadMoreBuilder: (page) =>
          context.read(postProvider).getPosts(artistName, page),
    ));

    final isRefreshing = useRefreshingState(infiniteListController.value);
    useAutoRefresh(infiniteListController.value, [artistName]);

    return Scaffold(
      body: SlidingUpPanel(
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        maxHeight: height,
        minHeight: height * 0.55,
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
                imageUrl: backgroundImageUrl,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    artistName.pretty,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                  artistInfo.maybeWhen(
                    data: (info) => Tags(
                      heightHorizontalScroll: 40,
                      spacing: 2,
                      horizontalScroll: true,
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      itemCount: info.otherNames.length,
                      itemBuilder: (index) {
                        return Chip(
                          shape: StadiumBorder(
                              side: BorderSide(color: Colors.grey)),
                          padding: EdgeInsets.all(4.0),
                          labelPadding: EdgeInsets.all(1.0),
                          visualDensity: VisualDensity.compact,
                          label: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.85),
                            child: Text(
                              info.otherNames[index].pretty,
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                    orElse: () => SizedBox.shrink(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
