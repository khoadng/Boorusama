import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_video_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class _PostListSwipeState extends State<PostListSwipe> {
  bool _notesIsVisible = false;
  // PostImage _postImage; // Caching

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      options: CarouselOptions(
          onPageChanged: (index, reason) {
            // Clear cache when page changed
            // _postImage = null;
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
          var _postImage = PostImage(
            controller: widget.postImageController,
            post: post,
            onLongPressed: () {},
            onNoteVisibleChanged: (value) {
              setState(() {
                _notesIsVisible = value;
              });
            },
          );
          return _postImage;
        }
      },
      itemCount: widget.posts.length,
    );
  }
}
