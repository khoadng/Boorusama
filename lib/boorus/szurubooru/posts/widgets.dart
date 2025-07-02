// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

class SzurubooruFileDetailsSection extends ConsumerWidget {
  const SzurubooruFileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class SzurubooruStatsTileSection extends ConsumerWidget {
  const SzurubooruStatsTileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SimplePostStatsTile(
            totalComments: post.commentCount,
            favCount: post.favoriteCount,
            score: post.score,
          ),
        ],
      ),
    );
  }
}
