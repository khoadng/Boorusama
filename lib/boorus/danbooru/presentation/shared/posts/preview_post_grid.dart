// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';

class PreviewPostGrid extends StatelessWidget {
  const PreviewPostGrid({
    Key? key,
    required this.posts,
    required this.imageQuality,
    this.physics,
  }) : super(key: key);

  final List<Post> posts;
  final ScrollPhysics? physics;
  final ImageQuality imageQuality;

  @override
  Widget build(BuildContext context) {
    void handleTap(Post post, int index) {
      AppRouter.router.navigateTo(
        context,
        '/post/detail',
        routeSettings: RouteSettings(
          arguments: [
            posts,
            index,
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: posts.length <= 3 ? 1 : 2,
      ),
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(1.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: GestureDetector(
            onTap: () => handleTap(posts[index], index),
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.3,
              fit: BoxFit.cover,
              imageUrl: _getImageUrl(
                posts[index],
                imageQuality,
              ),
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _getImageUrl(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.previewImageUrl;
  if (quality == ImageQuality.high) return post.normalImageUrl;
  return post.previewImageUrl;
}
