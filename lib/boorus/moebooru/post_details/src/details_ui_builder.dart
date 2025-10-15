// Project imports:
import '../../../../core/posts/details_parts/types.dart';
import '../../../../core/posts/details_parts/widgets.dart';
import '../../posts/types.dart';
import 'widgets/comment_section.dart';
import 'widgets/file_details_section.dart';
import 'widgets/information_section.dart';
import 'widgets/related_post_section.dart';
import 'widgets/toolbar.dart';

final moebooruPostDetailsUIBuilder = PostDetailsUIBuilder(
  previewSelectableParts: {
    DetailsPart.info,
    DetailsPart.toolbar,
    DetailsPart.tags,
    DetailsPart.fileDetails,
  },
  previewDefaultEnabledParts: {
    DetailsPart.info,
    DetailsPart.toolbar,
  },
  fullDefaultEnabledParts: {
    DetailsPart.info,
    DetailsPart.toolbar,
    DetailsPart.tags,
    DetailsPart.fileDetails,
    DetailsPart.artistInfo,
    DetailsPart.artistPosts,
    DetailsPart.relatedPosts,
    DetailsPart.comments,
    DetailsPart.characterList,
  },
  fullSelectableParts: {
    DetailsPart.info,
    DetailsPart.toolbar,
    DetailsPart.tags,
    DetailsPart.fileDetails,
    DetailsPart.artistInfo,
    DetailsPart.artistPosts,
    DetailsPart.relatedPosts,
    DetailsPart.comments,
    DetailsPart.characterList,
  },
  builders: {
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
    DetailsPart.relatedPosts: (context) => const MoebooruRelatedPostsSection(),
    DetailsPart.comments: (context) => const MoebooruCommentSection(),
    DetailsPart.characterList: (context) =>
        const DefaultInheritedCharacterPostsSection<MoebooruPost>(),
  },
);
