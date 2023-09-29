// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';

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
