// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PreviewPostList extends StatelessWidget {
  const PreviewPostList({
    super.key,
    required this.posts,
    this.physics,
  });

  final List<Post> posts;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: CachedNetworkImage(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.3,
            fit: BoxFit.cover,
            imageUrl: posts[index].previewImageUrl,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
