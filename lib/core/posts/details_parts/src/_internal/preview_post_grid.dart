// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../images/booru_image.dart';
import '../../../post/post.dart';
import '../../../post/tags.dart';
import '../../../post/widgets.dart';

class PreviewPostList<T extends Post> extends StatelessWidget {
  const PreviewPostList({
    required this.posts,
    required this.onTap,
    required this.imageUrl,
    super.key,
    this.physics,
    this.imageBuilder,
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
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          width: width ?? max(constraints.maxWidth / 6, 120),
                          forceFill: true,
                          aspectRatio: 0.6,
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
