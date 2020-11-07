import 'package:boorusama/domain/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  final String postHeroTag;

  const PostDetailPage({
    Key key,
    @required this.post,
    @required this.postHeroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appbarActions = <Widget>[];

    appbarActions.add(
      PopupMenuButton<String>(
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: "Test",
            child: ListTile(
              title: Text("Test"),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: appbarActions,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: postHeroTag,
            child: OptimizedCacheImage(
              fit: BoxFit.contain,
              width: 200.0,
              height: 200.0,
              imageUrl: post.normalImageUri.toString(),
            ),
          ),
          Text("ID: ${post.id}"),
        ],
      ),
    );
  }
}
