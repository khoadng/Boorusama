// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/black_listed_filter_decorator.dart';
import 'package:boorusama/boorus/danbooru/application/home/latest/latest_posts_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/no_image_filter_decorator.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/download/post_download_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/post_detail/artist_commetary/artist_commentary_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/post_detail/favorite/post_favorite_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/post_detail/post/post_detail_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'post_image_page.dart';
import 'widgets/post_tag_list.dart';
import 'widgets/post_video.dart';

final postDownloadStateNotifierProvider =
    StateNotifierProvider<PostDownloadStateNotifier>(
        (ref) => PostDownloadStateNotifier(ref));

final postFavoriteStateNotifierProvider =
    StateNotifierProvider<PostFavoriteStateNotifier>(
        (ref) => PostFavoriteStateNotifier(ref));

final artistCommentaryStateNotifierProvider =
    StateNotifierProvider<ArtistCommentaryStateNotifier>(
        (ref) => ArtistCommentaryStateNotifier(ref));

final postDetailStateNotifier = StateNotifierProvider<PostDetailStateNotifier>(
    (ref) => PostDetailStateNotifier(ref));

final latestPostsStateNotifierProvider =
    StateNotifierProvider<LatestStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  final settingsRepo = ref.watch(settingsProvider.future);
  final filteredPostRepo = BlackListedFilterDecorator(
      postRepository: postRepo, settingRepository: settingsRepo);
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  return LatestStateNotifier(removedNullImageRepo)..refresh();
});

class PostDetailPage extends StatefulWidget {
  PostDetailPage({
    Key key,
    @required this.post,
    @required this.heroTag,
    @required this.posts,
    @required this.intitialIndex,
  }) : super(key: key);

  final Post post;

  final List<Post> posts;
  final int intitialIndex;

  final String heroTag;

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        context.read(notesStateNotifierProvider).clearNotes();
        return Future.value(true);
      },
      child: CarouselSlider.builder(
          itemCount: widget.posts.length,
          itemBuilder: (context, index) {
            var postWidget;
            final post = widget.posts[index];
            if (post.isVideo) {
              postWidget = Container(
                  height: post.aspectRatio > 1.0
                      ? post.height / post.aspectRatio
                      : post.height,
                  child: PostVideo(post: post));
            } else {
              postWidget = Hero(
                tag: widget.heroTag,
                child: GestureDetector(
                  onTap: () => AppRouter.router.navigateTo(
                      context, "/posts/image",
                      routeSettings:
                          RouteSettings(arguments: [post, widget.heroTag])),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                          fit: BoxFit.fitWidth,
                          imageUrl: post.normalImageUri.toString())),
                ),
              );
            }

            return _DetailPageChild(
              post: widget.posts[index],
              postWidget: postWidget,
            );
          },
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1,
            initialPage: widget.intitialIndex,
            reverse: false,
            autoPlayCurve: Curves.fastOutSlowIn,
            scrollDirection: Axis.horizontal,
          )),
    );
  }
}

class _DetailPageChild extends StatefulWidget {
  const _DetailPageChild({
    Key key,
    @required this.post,
    @required this.postWidget,
  }) : super(key: key);

  final Post post;
  final Widget postWidget;

  @override
  __DetailPageChildState createState() => __DetailPageChildState();
}

class __DetailPageChildState extends State<_DetailPageChild> {
  int _favCount = 0;

  bool _showTranslated = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
        () => context
            .read(artistCommentaryStateNotifierProvider)
            .getCommentary(widget.post.id));

    Future.delayed(
        Duration.zero,
        () => context
            .read(postDetailStateNotifier)
            .getPostStatistics(widget.post.id));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(children: <Widget>[
                widget.postWidget,
                _buildTopShadowGradient(),
                _buildBackButton(context),
                _buildMoreVertButton(),
              ]),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
            Consumer(builder: (context, watch, child) {
              final state = watch(artistCommentaryStateNotifierProvider.state);
              return state.when(
                initial: () => SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                loading: () => SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                fetched: (commentary) {
                  if (!commentary.hasCommentary) {
                    // No artist comment, skip building this widget
                    return SliverToBoxAdapter(child: Center());
                  }

                  return _buildArtistCommentSection(
                      context, widget.post, commentary);
                },
                error: (name, message) => Text("Failed to load commentary"),
              );
            }),
            _buildSliverSpace(),
            _buildCommandToolBar(context, widget.post),
          ],
        ),
      ),
    );
  }

  Widget _buildTopShadowGradient() {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: const Alignment(0.0, 0.4),
              begin: const Alignment(0.0, -1),
              colors: <Color>[
                const Color(0x2F000000),
                Colors.black12.withOpacity(0.0)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildMoreVertButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PopupMenuButton<PostAction>(
          onSelected: (value) {
            switch (value) {
              case PostAction.download:
                // context
                //     .read(postDownloadStateNotifierProvider)
                //     .download(
                //         post.downloadLink, post.descriptiveName);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
            PopupMenuItem<PostAction>(
              value: PostAction.download,
              child: ListTile(
                // leading: const Icon(Icons.download_rounded),
                title: Text("Placeholder"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverSpace() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(5.0),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandToolBar(BuildContext context, Post post) {
    return Consumer(
      builder: (context, watch, child) {
        final state = watch(postDetailStateNotifier.state);

        return state.when(
          initial: () => SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())),
          loading: () => SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())),
          fetched: (statistics) {
            return SliverStickyHeader(
                header: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              color: Colors.white,
                              icon: Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => context
                                  .read(postDownloadStateNotifierProvider)
                                  .download(post)),
                          LikeButton(
                            size: 40,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            likeCount: statistics.commentCount,
                            likeBuilder: (isLiked) => Icon(
                              Icons.comment,
                              color: Colors.white,
                            ),
                            onTap: (isLiked) => showBarModalBottomSheet(
                              expand: false,
                              context: context,
                              builder: (context, controller) => CommentPage(
                                postId: post.id,
                              ),
                            ),
                          ),
                          LikeButton(
                            size: 40,
                            isLiked: statistics.isFavorited,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            likeCount: statistics.favCount,
                            likeBuilder: (isLiked) => Icon(
                              Icons.favorite,
                              color: isLiked ? Colors.red : Colors.white,
                            ),
                            onTap: (isLiked) {
                              //TODO: check for success here
                              if (!isLiked) {
                                context
                                    .read(postFavoriteStateNotifierProvider)
                                    .favorite(post.id);

                                return Future(() => true);
                              } else {
                                context
                                    .read(postFavoriteStateNotifierProvider)
                                    .unfavorite(post.id);
                                return Future(() => false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0,
                      thickness: 1.0,
                    ),
                  ],
                ),
                sliver: SliverPadding(
                  padding: EdgeInsets.only(left: 4),
                  sliver: PostTagList(
                      tagStringComma: post.tagString.toCommaFormat()),
                ));
          },
          error: (e, m) => SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }

  Widget _buildArtistCommentSection(
      BuildContext context, Post post, ArtistCommentary commentary) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(children: [
          ListTile(
            title: Text(post.tagStringArtist.pretty),
            leading: CircleAvatar(),
            trailing: PopupMenuButton<ArtistCommentaryAction>(
              icon: Icon(Icons.keyboard_arrow_down),
              onSelected: (value) {
                switch (value) {
                  case ArtistCommentaryAction.translate:
                    setState(() {
                      _showTranslated = !_showTranslated;
                    });
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ArtistCommentaryAction>>[
                PopupMenuItem<ArtistCommentaryAction>(
                  value: ArtistCommentaryAction.translate,
                  child: ListTile(
                    // leading: const Icon(Icons.download_rounded),
                    title: Text(
                        _showTranslated ? "Show Original" : "Show Translated"),
                  ),
                ),
              ],
            ),
          ),
          Html(
              data: commentary.isTranslated && _showTranslated
                  ? commentary.translated
                  : commentary.original),
        ]),
      ),
    ]));
  }
}

enum ArtistCommentaryAction { translate }
