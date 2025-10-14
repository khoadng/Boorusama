// Project imports:
import '../../../../../core/posts/details_parts/types.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../post/types.dart';
import 'widgets/danbooru_post_action_toolbar.dart';
import 'widgets/details_widgets.dart';

final danbooruPostDetailsUiBuilder = PostDetailsUIBuilder(
  previewAllowedParts: {
    DetailsPart.tags,
  },
  preview: {
    DetailsPart.info: (context) => const DanbooruInformationSection(),
    DetailsPart.toolbar: (context) =>
        const DanbooruInheritedPostActionToolbar(),
  },
  full: {
    DetailsPart.info: (context) => const DanbooruInformationSection(),
    DetailsPart.toolbar: (context) =>
        const DanbooruInheritedPostActionToolbar(),
    DetailsPart.artistInfo: (context) => const DanbooruArtistInfoSection(),
    DetailsPart.stats: (context) => const DanbooruStatsSection(),
    DetailsPart.tags: (context) => const DanbooruTagsSection(),
    DetailsPart.fileDetails: (context) => const DanbooruFileDetailsSection(),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<DanbooruPost>(),
    DetailsPart.pool: (context) => const DanbooruPoolTiles(),
    DetailsPart.relatedPosts: (context) => const DanbooruRelatedPostsSection2(),
    DetailsPart.characterList: (context) =>
        const DanbooruCharacterListSection(),
  },
);
