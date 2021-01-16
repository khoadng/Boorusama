import 'package:boorusama/application/download/post_download_state_notifier.dart';
import 'package:boorusama/application/post_detail/favorite/post_favorite_state_notifier.dart';
import 'package:boorusama/application/post_detail/post/post_detail_state_notifier.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/presentation/comment/comment_page.dart';
import 'package:boorusama/presentation/post_detail/post_image_page.dart';
import 'package:boorusama/presentation/post_detail/widgets/post_tag_list.dart';
import 'package:boorusama/presentation/post_detail/widgets/post_video.dart';
import 'package:boorusama/router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

final postDownloadStateNotifierProvider =
    StateNotifierProvider<PostDownloadStateNotifier>(
        (ref) => PostDownloadStateNotifier(ref));

final postDetailStateNotifierProvider =
    StateNotifierProvider<PostDetailStateNotifier>(
        (ref) => PostDetailStateNotifier(ref));

final postFavoriteStateNotifierProvider =
    StateNotifierProvider<PostFavoriteStateNotifier>(
        (ref) => PostFavoriteStateNotifier(ref));

class PostDetailPage extends StatefulWidget {
  PostDetailPage({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int _favCount = 0;

  @override
  void initState() {
    super.initState();
    _favCount = widget.post.favCount;
  }

  @override
  Widget build(BuildContext context) {
    var postWidget;
    if (widget.post.isVideo) {
      postWidget = PostVideo(post: widget.post);
    } else {
      postWidget = Hero(
        tag: "${widget.post.id}",
        child: GestureDetector(
          onTap: () => AppRouter.router.navigateTo(context, "/posts/image",
              routeSettings: RouteSettings(arguments: widget.post)),
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
      child: ProviderListener<PostDetailState>(
        provider: postDetailStateNotifierProvider.state,
        onChange: (context, state) {
          state.maybeWhen(
              fetched: (post) {
                setState(() {
                  _favCount = post.favCount;
                });
              },
              orElse: () {});
        },
        child: _buildPage(context, widget.post, postWidget),
      ),
    );
  }

  Widget _buildPage(BuildContext context, Post post, Widget postWidget) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.post.name.characterOnly.pretty
                              .capitalizeFirstofEach,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle1),
                      Text(
                          widget.post.name.copyRightOnly.pretty
                              .capitalizeFirstofEach,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Stack(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: FittedBox(
                              fit: BoxFit.scaleDown, child: postWidget)),
                    ],
                  ),
                ],
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10.0)),
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                padding: EdgeInsets.all(8.0),
                child: Text("Artist Commentary"),
              ),
            ])),
            SliverStickyHeader(
                header: ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        color: Colors.white,
                        icon: Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => context
                            .read(postDownloadStateNotifierProvider)
                            .download(post)),
                    IconButton(
                      icon: Icon(
                        Icons.comment,
                        color: Colors.white,
                      ),
                      onPressed: () => showBarModalBottomSheet(
                        expand: false,
                        context: context,
                        builder: (context, controller) => CommentPage(
                          postId: widget.post.id,
                        ),
                      ),
                    ),
                    LikeButton(
                      size: 24,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      likeCount: _favCount,
                      onTap: (isLiked) {
                        //TODO: check for success here
                        if (!isLiked) {
                          context
                              .read(postFavoriteStateNotifierProvider)
                              .favorite(widget.post.id);
                          // post.isFavorited = true;
                          _favCount++;
                          return Future(() => true);
                        } else {
                          context
                              .read(postFavoriteStateNotifierProvider)
                              .unfavorite(widget.post.id);
                          // widget.post.isFavorited = false;
                          _favCount--;
                          return Future(() => false);
                        }
                      },
                    ),
                  ],
                ),
                sliver: PostTagList(
                    tagStringComma: widget.post.tagString.toCommaFormat())),
          ],
        ),
      ),
    );
  }
}
