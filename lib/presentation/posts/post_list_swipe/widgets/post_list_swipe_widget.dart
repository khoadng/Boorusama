import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_video_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PostListSwipe extends StatefulWidget {
  PostListSwipe(
      {Key key,
      @required this.posts,
      this.initialPostIndex,
      this.onPostChanged})
      : super(key: key);

  final List<Post> posts;
  final int initialPostIndex;
  final ValueChanged<int> onPostChanged;

  @override
  _PostListSwipeState createState() => _PostListSwipeState();
}

class _PostListSwipeState extends State<PostListSwipe> {
  bool _notesIsVisible = false;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      options: CarouselOptions(
          initialPage: widget.initialPostIndex,
          viewportFraction: 1.0,
          scrollPhysics: _notesIsVisible
              ? const NeverScrollableScrollPhysics()
              : const ScrollPhysics(),
          enableInfiniteScroll: false,
          height: MediaQuery.of(context).size.height),
      itemBuilder: (context, index) {
        widget.onPostChanged(index);
        final post = widget.posts[index];
        if (post.isVideo) {
          return PostVideo(post: post);
        } else {
          return PostImage(
            post: post,
            onNoteVisibleChanged: (value) {
              setState(() {
                _notesIsVisible = value;
              });
            },
          );
        }
      },
      itemCount: widget.posts.length,
    );
  }
}
