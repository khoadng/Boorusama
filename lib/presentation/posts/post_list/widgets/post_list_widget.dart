import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_list_bottom_loader_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostList extends StatefulWidget {
  PostList(
      {Key key,
      @required this.posts,
      @required this.onMaxItemReached,
      @required this.scrollThreshold,
      @required this.scrollController})
      : super(key: key);

  final List<Post> posts;
  final ValueChanged onMaxItemReached;
  final scrollThreshold;
  final scrollController;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final image = CachedNetworkImage(
          imageUrl: post.previewImageUri.toString(),
          imageBuilder: (context, imageProvider) => Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                image:
                    DecorationImage(image: imageProvider, fit: BoxFit.contain),
              )),
          placeholder: (context, url) => FractionallySizedBox(
            widthFactor: 0.1,
            heightFactor: 0.1,
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        );

        return index >= widget.posts.length ? BottomLoader() : image;
      },
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
      controller: widget.scrollController..addListener(_onScroll),
    );
  }

  void _onScroll() {
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.position.pixels;
    final currentThresholdPercent = currentScroll / maxScroll;

    if (currentThresholdPercent >= widget.scrollThreshold) {
      widget.onMaxItemReached(null);
    }
  }
}
