// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/widgets/image_grid_item.dart';

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
        child: Builder(
          builder: (context) => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: switch (Screen.of(context).size) {
                ScreenSize.small => 3,
                ScreenSize.medium => 4,
                ScreenSize.large => 6,
                ScreenSize.veryLarge => 7,
              },
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
      height: context.screenHeight * 0.22,
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
