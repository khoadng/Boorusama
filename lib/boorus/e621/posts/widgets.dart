// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/artists/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/search/search/routes.dart';
import 'types.dart';

class E621ArtistSection extends ConsumerWidget {
  const E621ArtistSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<E621Post>(context);

    final commentary = post.description;

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary: ArtistCommentary.description(commentary),
        artistTags: post.artistTags,
        source: post.source,
      ),
    );
  }
}

class E621UploaderFileDetailTile extends ConsumerWidget {
  const E621UploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<E621Post>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
        onSearch: () => goToSearchPage(ref, tag: 'user:$name'),
      ),
    };
  }
}

final kE621PostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<E621Post>(
          showSource: true,
        ),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<E621Post>(),
  },
  full: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<E621Post>(
          showSource: true,
        ),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<E621Post>(),
    DetailsPart.artistInfo: (context) => const E621ArtistSection(),
    DetailsPart.tags: (context) => const DefaultInheritedTagsTile<E621Post>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<E621Post>(
          uploader: E621UploaderFileDetailTile(),
        ),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<E621Post>(),
    DetailsPart.characterList: (context) =>
        const DefaultInheritedCharacterPostsSection<E621Post>(),
  },
);
