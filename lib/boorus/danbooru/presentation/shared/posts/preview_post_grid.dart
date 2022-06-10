// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class PreviewPostGrid extends StatelessWidget {
  const PreviewPostGrid({
    Key? key,
    required this.posts,
    this.physics,
  }) : super(key: key);

  final List<Post> posts;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    void handleTap(Post post, int index) {
      AppRouter.router.navigateTo(
        context,
        "/post/detail",
        routeSettings: RouteSettings(
          arguments: [
            posts,
            index,
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(3.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: GestureDetector(
            onTap: () => handleTap(posts[index], index),
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.3,
              fit: BoxFit.cover,
              imageUrl: posts[index].previewImageUrl,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
