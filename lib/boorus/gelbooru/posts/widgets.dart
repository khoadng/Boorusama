// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/search/search/routes.dart';
import 'types.dart';

class GelbooruUploaderFileDetailTile extends ConsumerWidget {
  const GelbooruUploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruPost>(context);
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
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<GelbooruPost>(
          uploader: GelbooruUploaderFileDetailTile(),
        ),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<GelbooruPost>(),
    DetailsPart.characterList: (context) =>
        const DefaultInheritedCharacterPostsSection<GelbooruPost>(),
  },
);
