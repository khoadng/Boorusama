// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/e621/artists/artists.dart';
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/boorus/e621/tags/tags.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/posts/details.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/router.dart';

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
              .map((tag) => SliverArtistPostList(
                    tag: tag,
                    child: ref.watch(e621ArtistPostsProvider(tag)).maybeWhen(
                          data: (data) => SliverPreviewPostGrid(
                            posts: data,
                            onTap: (postIdx) => goToPostDetailsPageFromPosts(
                              context: context,
                              posts: data,
                              initialIndex: postIdx,
                            ),
                            imageUrl: (item) => item.thumbnailFromSettings(
                                ref.watch(imageListingSettingsProvider)),
                          ),
                          orElse: () =>
                              const SliverPreviewPostGridPlaceholder(),
                        ),
                  ))
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
          ...post.artistTags.map((e) => Tag.noCount(
                name: e,
                category: e621ArtistTagCategory,
              )),
          ...post.characterTags.map((e) => Tag.noCount(
                name: e,
                category: e621CharacterTagCategory,
              )),
          ...post.speciesTags.map((e) => Tag.noCount(
                name: e,
                category: e621SpeciesTagCategory,
              )),
          ...post.copyrightTags.map((e) => Tag.noCount(
                name: e,
                category: e621CopyrightTagCategory,
              )),
          ...post.generalTags.map((e) => Tag.noCount(
                name: e,
                category: e621GeneralTagCategory,
              )),
          ...post.metaTags.map((e) => Tag.noCount(
                name: e,
                category: e621MetaTagCagegory,
              )),
          ...post.loreTags.map((e) => Tag.noCount(
                name: e,
                category: e621LoreTagCategory,
              )),
        ]),
      ),
    );
  }
}
