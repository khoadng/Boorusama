// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

class GelbooruFileDetailsSection extends StatelessWidget {
  const GelbooruFileDetailsSection({
    super.key,
    this.initialExpanded = false,
  });

  final bool initialExpanded;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        initialExpanded: initialExpanded,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

final kGelbooruPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<GelbooruPost>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<GelbooruPost>(),
    DetailsPart.source: (context) =>
        const DefaultInheritedSourceSection<GelbooruPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<GelbooruPost>(),
    DetailsPart.fileDetails: (context) => const GelbooruFileDetailsSection(),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<GelbooruPost>(),
    DetailsPart.characterList: (context) =>
        const DefaultInheritedCharacterPostsSection<GelbooruPost>(),
  },
);
