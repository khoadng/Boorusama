// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../core/artists/artists.dart';
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/settings/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../artists/artists.dart';
import '../tags/tags.dart';
import 'posts.dart';

class E621ArtistPostsSection extends ConsumerWidget {
  const E621ArtistPostsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<E621Post>(context);

    return MultiSliver(
      children: post.artistTags.isNotEmpty
          ? post.artistTags
              .map(
                (tag) => SliverArtistPostList(
                  tag: tag,
                  child: ref
                      .watch(
                        e621ArtistPostsProvider(
                          (ref.watchConfigFilter, ref.watchConfigSearch, tag),
                        ),
                      )
                      .maybeWhen(
                        data: (data) => SliverPreviewPostGrid(
                          posts: data,
                          onTap: (postIdx) => goToPostDetailsPageFromPosts(
                            context: context,
                            posts: data,
                            initialIndex: postIdx,
                            initialThumbnailUrl:
                                data[postIdx].thumbnailFromSettings(
                              ref.watch(imageListingQualityProvider),
                            ),
                          ),
                          imageUrl: (item) => item.thumbnailFromSettings(
                            ref.watch(imageListingQualityProvider),
                          ),
                        ),
                        orElse: () => const SliverPreviewPostGridPlaceholder(),
                      ),
                ),
              )
              .toList()
          : [],
    );
  }
}

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

class E621TagsTile extends ConsumerWidget {
  const E621TagsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<E621Post>(context);

    return SliverToBoxAdapter(
      child: TagsTile(
        post: post,
        tags: createTagGroupItems([
          ...post.artistTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621ArtistTagCategory,
            ),
          ),
          ...post.characterTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621CharacterTagCategory,
            ),
          ),
          ...post.speciesTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621SpeciesTagCategory,
            ),
          ),
          ...post.copyrightTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621CopyrightTagCategory,
            ),
          ),
          ...post.generalTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621GeneralTagCategory,
            ),
          ),
          ...post.metaTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621MetaTagCagegory,
            ),
          ),
          ...post.loreTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621LoreTagCategory,
            ),
          ),
        ]),
      ),
    );
  }
}
