import 'package:boorusama/domain/posts/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: postHeroTag,
            child: CachedNetworkImage(
              imageUrl: post.normalImageUri.toString(),
              fit: BoxFit.contain,
              width: 200.0,
              height: 200.0,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID: ${post.id}"),
                Text("Date: ${post.createdAt.toString()}"),
                Text("Source: ${post.source}"),
                Text("Rating: ${post.rating.toString().split('.').last}"),
                Text("Score: ${post.score}"),
                Text("Favorites: ${post.favCount}"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
