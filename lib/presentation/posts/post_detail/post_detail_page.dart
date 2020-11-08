import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/posts/post_detail/widgets/post_tag_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  final String postHeroTag;
  final List<Tag> tags;

  const PostDetailPage({
    Key key,
    @required this.post,
    @required this.tags,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: appbarActions,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: postHeroTag,
            child: CachedNetworkImage(
              imageUrl: post.normalImageUri.toString(),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
            ),
          ),
          Expanded(child: PostTagList(tags: tags)),
          // Expanded(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text("ID: ${post.id}"),
          //       Text("Date: ${post.createdAt.toString()}"),
          //       Text("Source: ${post.source}"),
          //       Text("Rating: ${post.rating.toString().split('.').last}"),
          //       Text("Score: ${post.score}"),
          //       Text("Favorites: ${post.favCount}"),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
