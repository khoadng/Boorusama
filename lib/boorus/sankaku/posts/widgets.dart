// Project imports:
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

final kSankakuPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<SankakuPost>(
          showSource: true,
        ),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<SankakuPost>(),
  },
  full: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<SankakuPost>(
          showSource: true,
        ),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<SankakuPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<SankakuPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<SankakuPost>(),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<SankakuPost>(),
  },
);
