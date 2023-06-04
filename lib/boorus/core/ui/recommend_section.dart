// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/ui/preview_post_grid.dart';

class RecommendPostSection<T extends Post> extends ConsumerWidget {
  const RecommendPostSection({
    super.key,
    required this.posts,
    required this.header,
    required this.onTap,
    this.grid = true,
    required this.imageUrl,
  });

  final List<T> posts;
  final Widget header;
  final void Function(int index) onTap;
  final bool grid;
  final String Function(T item) imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.all(4),
          child: grid
              ? PreviewPostGrid<T>(
                  cacheManager: ref.watch(previewImageCacheManagerProvider),
                  posts: posts,
                  onTap: onTap,
                  imageUrl: imageUrl,
                )
              : PreviewPostList<T>(
                  cacheManager: ref.watch(previewImageCacheManagerProvider),
                  posts: posts,
                  onTap: onTap,
                  imageUrl: imageUrl,
                ),
        ),
      ],
    );
  }
}
