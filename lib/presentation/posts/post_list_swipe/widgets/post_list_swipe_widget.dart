import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/comments/comment_page.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_tag_list.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_video_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostListSwipe extends StatefulWidget {
  PostListSwipe(
      {Key key,
      @required this.posts,
      @required this.postImageController,
      this.initialPostIndex,
      this.onPostChanged})
      : super(key: key);

  final List<Post> posts;
  final int initialPostIndex;
  final ValueChanged<int> onPostChanged;
  final PostImageController postImageController;

  @override
  _PostListSwipeState createState() => _PostListSwipeState();
}

class _PostListSwipeState extends State<PostListSwipe>
    with AutomaticKeepAliveClientMixin<PostListSwipe> {
  bool _notesIsVisible = false;
  int _currentPostIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentPostIndex = widget.initialPostIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomAppBar(context),
      body: CarouselSlider.builder(
        options: CarouselOptions(
            onPageChanged: (index, reason) {
              widget.onPostChanged(index);
            },
            initialPage: widget.initialPostIndex,
            viewportFraction: 1.0,
            scrollPhysics: _notesIsVisible
                ? const NeverScrollableScrollPhysics()
                : const ScrollPhysics(),
            enableInfiniteScroll: false,
            height: MediaQuery.of(context).size.height),
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          if (post.isVideo) {
            return PostVideo(post: post);
          } else {
            return PostImage(
              controller: widget.postImageController,
              post: post,
              onLongPressed: () {
                BlocProvider.of<TagListBloc>(context)
                    .add(GetTagList(post.tagString.toCommaFormat(), 1));

                showBarModalBottomSheet(
                  expand: false,
                  context: context,
                  builder: (context, controller) => PostTagList(),
                );
              },
              onNoteVisibleChanged: (value) {
                setState(() {
                  _notesIsVisible = value;
                });
              },
            );
          }
        },
        itemCount: widget.posts.length,
      ),
    );
  }

  Widget bottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CupertinoButton(
            child: Icon(
              Icons.download_rounded,
              size: 28,
            ),
            onPressed: () {},
          ),
          CupertinoButton(
            child: Icon(CupertinoIcons.heart, size: 28),
            onPressed: () => BlocProvider.of<PostFavoritesBloc>(context)
                .add(AddToFavorites(widget.posts[_currentPostIndex].id)),
          ),
          CupertinoButton(
            child: Icon(Icons.comment, size: 28),
            onPressed: () {
              //           BlocProvider.of<TagListBloc>(context)
              // .add(GetTagList(post.tagString.toCommaFormat(), 1));

              showBarModalBottomSheet(
                expand: false,
                context: context,
                builder: (context, controller) => CommentPage(
                  postId: widget.posts[_currentPostIndex].id,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
