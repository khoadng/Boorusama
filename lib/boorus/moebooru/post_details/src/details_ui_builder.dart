// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/posts/details/types.dart';
import '../../../../core/posts/details_parts/types.dart';
import '../../../../core/posts/details_parts/widgets.dart';
import '../../posts/types.dart';
import '../providers.dart';
import 'widgets/comment_section.dart';
import 'widgets/file_details_section.dart';
import 'widgets/information_section.dart';
import 'widgets/related_post_section.dart';
import 'widgets/toolbar.dart';

final moebooruPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.info: (context) => const MoebooruInformationSection(),
    DetailsPart.toolbar: (context) => const MoebooruPostDetailsActionToolbar(),
  },
  full: {
    DetailsPart.info: (context) => const MoebooruInformationSection(),
    DetailsPart.toolbar: (context) => const MoebooruPostDetailsActionToolbar(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<MoebooruPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<MoebooruPost>(
          uploader: MoebooruUploaderFileDetailTile(),
        ),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<MoebooruPost>(),
    DetailsPart.uploaderPosts: (context) =>
        const MoebooruUploaderPostsSection(),
    DetailsPart.relatedPosts: (context) => const MoebooruRelatedPostsSection(),
    DetailsPart.comments: (context) => const MoebooruCommentSection(),
    DetailsPart.characterList: (context) =>
        const DefaultInheritedCharacterPostsSection<MoebooruPost>(),
  },
);

class MoebooruUploaderPostsSection extends ConsumerWidget {
  const MoebooruUploaderPostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);

    return UploaderPostsSection<MoebooruPost>(
      query: ref.watch(
        moebooruUploaderQueryProvider(post),
      ),
    );
  }
}
