// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

class Shimmie2FileDetailsSection extends ConsumerWidget {
  const Shimmie2FileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<Shimmie2Post>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

final kShimmie2PostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<Shimmie2Post>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<Shimmie2Post>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedBasicTagsTile<Shimmie2Post>(),
    DetailsPart.fileDetails: (context) => const Shimmie2FileDetailsSection(),
  },
);
