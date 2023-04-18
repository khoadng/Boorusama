// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/booru_image.dart';

class PreviewPostGrid extends StatelessWidget {
  const PreviewPostGrid({
    super.key,
    required this.posts,
    required this.imageQuality,
    required this.onTap,
    this.physics,
    this.cacheManager,
  });

  final List<DanbooruPostData> posts;
  final ScrollPhysics? physics;
  final ImageQuality imageQuality;
  final void Function(int index) onTap;
  final CacheManager? cacheManager;

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
          itemBuilder: (context, index) {
            final post = posts[index].post;

            return GestureDetector(
              onTap: () => onTap(index),
              child: LayoutBuilder(
                builder: (context, constraints) => BooruImage(
                  imageUrl: _getImageUrl(post, imageQuality),
                  placeholderUrl: post.thumbnailImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PreviewPostList extends StatelessWidget {
  const PreviewPostList({
    super.key,
    required this.posts,
    required this.imageQuality,
    required this.onTap,
    this.physics,
    this.cacheManager,
  });

  final List<DanbooruPostData> posts;
  final ScrollPhysics? physics;
  final ImageQuality imageQuality;
  final void Function(int index) onTap;
  final CacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].post;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: LayoutBuilder(
                    builder: (context, constraints) => BooruImage(
                      aspectRatio: 0.6,
                      imageUrl: post.isAnimated
                          ? post.thumbnailImageUrl
                          : post.sampleImageUrl,
                      placeholderUrl: post.thumbnailImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

String _getImageUrl(DanbooruPost post, ImageQuality quality) {
  if (post.isAnimated) return post.thumbnailImageUrl;
  if (quality == ImageQuality.high) return post.sampleImageUrl;

  return post.thumbnailImageUrl;
}
