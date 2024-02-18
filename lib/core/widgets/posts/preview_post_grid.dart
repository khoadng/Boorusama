// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme/theme_utils.dart';
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
        removeBottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: switch (
                  screenWidthToDisplaySize(constraints.maxWidth)) {
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

              return ImageGridItem(
                isGif: post.isGif,
                isAI: post.isAI,
                onTap: () => onTap(index),
                isAnimated: post.isAnimated,
                isTranslated: post.isTranslated,
                image: BooruImage(
                  forceFill: true,
                  imageUrl: imageUrl(post),
                  placeholderUrl: post.thumbnailImageUrl,
                  fit: BoxFit.cover,
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
    this.imageBuilder,
    required this.imageUrl,
    this.width,
    this.height,
  });

  final List<T> posts;
  final ScrollPhysics? physics;
  final void Function(int index) onTap;
  final Widget Function(T item)? imageBuilder;
  final String Function(T item) imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: height ?? 200,
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
                      isGif: post.isGif,
                      isAI: post.isAI,
                      isAnimated: post.isAnimated,
                      isTranslated: post.isTranslated,
                      onTap: () => onTap(index),
                      image: imageBuilder != null
                          ? imageBuilder!(post)
                          : BooruImage(
                              width:
                                  width ?? max(constraints.maxWidth / 6, 120),
                              forceFill: true,
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
      ),
    );
  }
}

class PreviewPostListPlaceholder extends StatelessWidget {
  const PreviewPostListPlaceholder({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: height ?? 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 20,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: width ?? max(constraints.maxWidth / 6, 120),
                    height: height ?? 200,
                    decoration: BoxDecoration(
                      color:
                          context.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PreviewPostGridPlaceholder extends StatelessWidget {
  const PreviewPostGridPlaceholder({
    super.key,
    this.imageCount = 30,
  });

  final int? imageCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: switch (
                  screenWidthToDisplaySize(constraints.maxWidth)) {
                ScreenSize.small => 3,
                ScreenSize.medium => 4,
                ScreenSize.large => 6,
                ScreenSize.veryLarge => 7,
              },
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imageCount,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
