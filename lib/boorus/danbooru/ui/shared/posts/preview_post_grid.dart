// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/core.dart';

class PreviewPostGrid extends StatelessWidget {
  const PreviewPostGrid({
    super.key,
    required this.posts,
    required this.imageQuality,
    required this.onTap,
    this.physics,
  });

  final List<PostData> posts;
  final ScrollPhysics? physics;
  final ImageQuality imageQuality;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          shrinkWrap: true,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: _getImageUrl(
                  posts[index].post,
                  imageQuality,
                ),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
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
