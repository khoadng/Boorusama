import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_list_swipe_widget.dart';
import 'package:flutter/material.dart';

class PostListSwipePage extends StatefulWidget {
  PostListSwipePage({Key key, @required this.posts, this.initialPostIndex})
      : super(key: key);

  final posts;
  final initialPostIndex;

  @override
  _PostListSwipePageState createState() => _PostListSwipePageState();
}

class _PostListSwipePageState extends State<PostListSwipePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PostListSwipe(
        posts: widget.posts,
        initialPostIndex: widget.initialPostIndex,
      ),
    );
  }
}
