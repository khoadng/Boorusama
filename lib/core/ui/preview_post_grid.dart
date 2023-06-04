// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';

class PreviewPostGrid<T extends Post> extends StatelessWidget {
  const PreviewPostGrid({
    super.key,
    required this.posts,
    required this.onTap,
    this.physics,
    this.cacheManager,
    required this.imageUrl,
  });

  final List<T> posts;
  final ScrollPhysics? physics;
  final void Function(int index) onTap;
  final CacheManager? cacheManager;
  final String Function(T item) imageUrl;

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
            final post = posts[index];

            return LayoutBuilder(
              builder: (context, constraints) => ImageGridItem(
                onTap: () => onTap(index),
                isAnimated: post.isAnimated,
                isTranslated: post.isTranslated,
                image: BooruImage(
                  imageUrl: imageUrl(post),
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

class PreviewPostList<T extends Post> extends StatelessWidget {
  const PreviewPostList({
    super.key,
    required this.posts,
    required this.onTap,
    this.physics,
    this.cacheManager,
    this.imageBuilder,
    required this.imageUrl,
  });

  final List<T> posts;
  final ScrollPhysics? physics;
  final void Function(int index) onTap;
  final CacheManager? cacheManager;
  final Widget Function(T item)? imageBuilder;
  final String Function(T item) imageUrl;

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
              final post = posts[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ImageGridItem(
                    isAnimated: post.isAnimated,
                    isTranslated: post.isTranslated,
                    onTap: () => onTap(index),
                    image: imageBuilder != null
                        ? imageBuilder!(post)
                        : BooruImage(
                            aspectRatio: 0.6,
                            imageUrl: imageUrl(post),
                            placeholderUrl: post.thumbnailImageUrl,
                            fit: BoxFit.cover,
                          )),
              );
            },
          ),
        ),
      ),
    );
  }
}
