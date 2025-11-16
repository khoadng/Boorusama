// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/posts/details/types.dart';
import '../../../../../core/posts/details_parts/types.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../post/types.dart';
import 'providers.dart';
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
    DetailsPart.artistPosts: (context) => const DanbooruArtistPostsSection(),
    DetailsPart.uploaderPosts: (context) =>
        const DanbooruUploaderPostsSection(),
    DetailsPart.pool: (context) => const DanbooruPoolTiles(),
    DetailsPart.relatedPosts: (context) => const DanbooruRelatedPostsSection2(),
    DetailsPart.characterList: (context) =>
        const DanbooruCharacterListSection(),
  },
);

class DanbooruArtistPostsSection extends StatelessWidget {
  const DanbooruArtistPostsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultInheritedArtistPostsSection<DanbooruPost>(
      filterQuery: CustomPostFilterQuery(
        includeWhen: (post) => !post.isBanned,
      ),
    );
  }
}

class DanbooruUploaderPostsSection extends ConsumerWidget {
  const DanbooruUploaderPostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return UploaderPostsSection<DanbooruPost>(
      query: ref.watch(
        danbooruUploaderQueryProvider(post),
      ),
      filterQuery: CustomPostFilterQuery(
        includeWhen: (post) => !post.isBanned,
      ),
    );
  }
}
