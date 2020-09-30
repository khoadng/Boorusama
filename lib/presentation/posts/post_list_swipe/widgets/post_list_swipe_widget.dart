import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class PostListSwipe extends StatefulWidget {
  PostListSwipe({Key key, @required this.posts}) : super(key: key);

  final List<Post> posts;

  @override
  _PostListSwipeState createState() => _PostListSwipeState();
}

class _PostListSwipeState extends State<PostListSwipe> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        //TODO: use seperate image instead of general image
        final image = PostImage(imageUrl: post.previewImageUri.toString());

        return image;
      },
      itemCount: widget.posts.length,
    );
  }
}
