import 'package:boorusama/domain/posts/post.dart';
import 'package:flutter/material.dart';

class PostList extends StatelessWidget {
  final List<Post> posts;

  PostList({this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemBuilder: (context, index) {
        var post = this.posts[index];

        return Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.contain,
                  image: NetworkImage(post.previewImageUri.toString())),
              borderRadius: BorderRadius.circular(6)),
          width: 150,
          height: 150,
        );
      },
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
    );
  }
}
