import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PostListSwipe extends StatefulWidget {
  PostListSwipe({Key key, @required this.posts, this.initialPostIndex})
      : super(key: key);

  final List<Post> posts;
  final int initialPostIndex;

  @override
  _PostListSwipeState createState() => _PostListSwipeState();
}

class _PostListSwipeState extends State<PostListSwipe> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      options: CarouselOptions(
          initialPage: widget.initialPostIndex, viewportFraction: 1.0),
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final image = PostImage(imageUrl: post.normalImageUri.toString());

        return image;
      },
      itemCount: widget.posts.length,
    );
  }
}
