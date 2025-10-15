// Project imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../../core/blacklists/providers.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/details/types.dart';
import '../../../../../core/posts/details_parts/types.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../core/posts/listing/providers.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/posts/post/types.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../foundation/riverpod/riverpod.dart';
import '../../../users/creator/providers.dart';
import '../../post/types.dart';
import 'widgets/danbooru_post_action_toolbar.dart';
import 'widgets/details_widgets.dart';

final danbooruPostDetailsUiBuilder = PostDetailsUIBuilder(
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
    DetailsPart.artistInfo,
    DetailsPart.stats,
    DetailsPart.tags,
    DetailsPart.fileDetails,
    DetailsPart.artistPosts,
    DetailsPart.pool,
    DetailsPart.relatedPosts,
    DetailsPart.characterList,
  },
  fullSelectableParts: {
    DetailsPart.info,
    DetailsPart.toolbar,
    DetailsPart.artistInfo,
    DetailsPart.stats,
    DetailsPart.tags,
    DetailsPart.fileDetails,
    DetailsPart.artistPosts,
    DetailsPart.pool,
    DetailsPart.relatedPosts,
    DetailsPart.characterList,
  },
  builders: {
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

final detailsUploadersPostsProvider = FutureProvider.autoDispose
    .family<List<Post>, (BooruConfigFilter, BooruConfigSearch, String?)>((
      ref,
      params,
    ) {
      ref.cacheFor(const Duration(seconds: 30));

      final (filter, search, artistName) = params;
      return ref
          .watch(postRepoProvider(search))
          .getPostsFromTagWithBlacklist(
            tag: artistName,
            blacklist: ref.watch(blacklistTagsProvider(filter).future),
            options: PostFetchOptions.raw,
          );
    });

class DanbooruUploaderPostsSection extends ConsumerWidget {
  const DanbooruUploaderPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);
    final auth = ref.watchConfigAuth;

    final thumbUrlBuilder = ref.watch(gridThumbnailUrlGeneratorProvider(auth));
    final thumbSettings = ref.watch(gridThumbnailSettingsProvider(auth));
    final uploader = ref.watch(danbooruCreatorProvider(post.uploaderId));

    return MultiSliver(
      children: [
        if (uploader?.name case final name?)
          SliverDetailsPostList(
            onTap: () {
              goToSearchPage(ref, tag: 'user:$name');
            },
            tag: name,
            child: ref
                .watch(
                  detailsUploadersPostsProvider(
                    (
                      ref.watchConfigFilter,
                      ref.watchConfigSearch,
                      name,
                    ),
                  ),
                )
                .maybeWhen(
                  data: (data) => SliverPreviewPostGrid(
                    posts: data,
                    imageUrl: (p) => thumbUrlBuilder.generateUrl(
                      p,
                      settings: thumbSettings,
                    ),
                  ),
                  orElse: () => const SliverPreviewPostGridPlaceholder(),
                ),
          ),
      ],
    );
  }
}
