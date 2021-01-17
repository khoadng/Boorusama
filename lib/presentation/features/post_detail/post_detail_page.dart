import 'dart:math';

import 'package:boorusama/application/download/post_download_state_notifier.dart';
import 'package:boorusama/application/post_detail/artist_commetary/artist_commentary_state_notifier.dart';
import 'package:boorusama/application/post_detail/favorite/post_favorite_state_notifier.dart';
import 'package:boorusama/application/post_detail/post/post_detail_state_notifier.dart';
import 'package:boorusama/domain/posts/artist_commentary.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/presentation/features/comment/comment_page.dart';
import 'package:boorusama/router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

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

class PostDetailPage extends StatefulWidget {
  PostDetailPage({
    Key key,
    @required this.post,
    @required this.heroTag,
  }) : super(key: key);

  final Post post;
  final String heroTag;

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int _favCount = 0;
  bool _showTranslated = true;

  @override
  void initState() {
    super.initState();
    _favCount = widget.post.favCount;
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
    var postWidget;
    if (widget.post.isVideo) {
      postWidget = PostVideo(post: widget.post);
    } else {
      postWidget = Hero(
        tag: widget.heroTag,
        child: GestureDetector(
          onTap: () => AppRouter.router.navigateTo(context, "/posts/image",
              routeSettings:
                  RouteSettings(arguments: [widget.post, widget.heroTag])),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                  imageUrl: widget.post.normalImageUri.toString())),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        context.read(notesStateNotifierProvider).clearNotes();
        return Future.value(true);
      },
      child: _buildPage(context, widget.post, postWidget),
    );
  }

  Widget _buildPage(BuildContext context, Post post, Widget postWidget) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Stack(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: FittedBox(
                              fit: BoxFit.fitWidth, child: postWidget)),
                      // Text("")
                    ],
                  ),
                ],
              ),
            ),
            Consumer(builder: (context, watch, child) {
              final state = watch(artistCommentaryStateNotifierProvider.state);
              return state.when(
                initial: () => _buildLoading(),
                loading: () => _buildLoading(),
                fetched: (commentary) {
                  if (!commentary.hasCommentary) {
                    // No artist comment, skip building this widget
                    return SliverList(
                        delegate: SliverChildListDelegate([Center()]));
                  }

                  return _buildArtistCommentSection(context, post, commentary);
                },
                error: (name, message) => Text("Failed to load commentary"),
              );
            }),
            _buildSliverSpace(),
            _buildCommandToolBar(context, post),
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
          initial: () => _buildCommandToolbarPlaceholder(context, post),
          loading: () => _buildCommandToolbarPlaceholder(context, post),
          fetched: (statistics) {
            return SliverStickyHeader(
                header: Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
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
                            postId: widget.post.id,
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
                                .favorite(widget.post.id);

                            return Future(() => true);
                          } else {
                            context
                                .read(postFavoriteStateNotifierProvider)
                                .unfavorite(widget.post.id);
                            return Future(() => false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                sliver: PostTagList(
                    tagStringComma: widget.post.tagString.toCommaFormat()));
          },
          error: (e, m) => _buildCommandToolbarPlaceholder(context, post),
        );
      },
    );
  }

  Widget _buildCommandToolbarPlaceholder(BuildContext context, Post post) {
    return SliverStickyHeader(
        header: ButtonBar(
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
              likeBuilder: (isLiked) => Icon(
                Icons.comment,
                color: Colors.white,
              ),
              countBuilder: (likeCount, isLiked, text) =>
                  CircularProgressIndicator(),
              onTap: (isLiked) => showBarModalBottomSheet(
                expand: false,
                context: context,
                builder: (context, controller) => CommentPage(
                  postId: widget.post.id,
                ),
              ),
            ),
            LikeButton(
              size: 40,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              likeBuilder: (isLiked) => Icon(
                Icons.favorite,
                color: isLiked ? Colors.red : Colors.white,
              ),
              countBuilder: (likeCount, isLiked, text) =>
                  CircularProgressIndicator(),
              onTap: (isLiked) {
                //TODO: check for success here
                if (!isLiked) {
                  context
                      .read(postFavoriteStateNotifierProvider)
                      .favorite(widget.post.id);

                  return Future(() => true);
                } else {
                  context
                      .read(postFavoriteStateNotifierProvider)
                      .unfavorite(widget.post.id);
                  return Future(() => false);
                }
              },
            ),
          ],
        ),
        sliver:
            PostTagList(tagStringComma: widget.post.tagString.toCommaFormat()));
  }

  Widget _buildArtistCommentSection(
      BuildContext context, Post post, ArtistCommentary commentary) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.0)),
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0),
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

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.post.name.characterOnly.pretty.capitalizeFirstofEach,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle1),
              Text(widget.post.name.copyRightOnly.pretty.capitalizeFirstofEach,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() => SliverList(
        delegate: SliverChildListDelegate([
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Shimmer.fromColors(
              highlightColor: Colors.grey[500],
              baseColor: Colors.grey[700],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(),
                    title: Container(
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.6),
                      width: 10,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    width: Random().nextDouble() * 100 +
                        MediaQuery.of(context).size.width * 0.3,
                    height: 20,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    width: Random().nextDouble() * 100 +
                        MediaQuery.of(context).size.width * 0.3,
                    height: 20,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    width: Random().nextDouble() * 100 +
                        MediaQuery.of(context).size.width * 0.3,
                    height: 20,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
}

enum ArtistCommentaryAction { translate }
