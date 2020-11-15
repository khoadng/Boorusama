import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/lists/sliver_image_grid.dart';
import 'package:flutter/material.dart';

class AllPostsPage extends StatefulWidget {
  AllPostsPage({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final List<Post> posts;

  @override
  _AllPostsPageState createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        // This Builder is needed to provide a BuildContext that is "inside"
        // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
        // find the NestedScrollView.
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: EdgeInsets.all(0.0),
                    ),
                  ],
                ),
              ),
              SliverPostList(length: widget.posts.length, posts: widget.posts),
            ],
          );
        },
      ),
    );
  }
}
