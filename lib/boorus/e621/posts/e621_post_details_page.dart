// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/artists/artists.dart';
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/boorus/e621/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/router.dart';

class E621PostDetailsPage extends ConsumerStatefulWidget {
  const E621PostDetailsPage({
    super.key,
  });

  @override
  ConsumerState<E621PostDetailsPage> createState() =>
      _E621PostDetailsPageState();
}

class _E621PostDetailsPageState extends ConsumerState<E621PostDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<E621Post>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      sliverArtistPostsBuilder: (context, post) => post.artistTags.isNotEmpty
          ? post.artistTags
              .map((tag) => ArtistPostList(
                    tag: tag,
                    builder: (tag) =>
                        ref.watch(e621ArtistPostsProvider(tag)).maybeWhen(
                              data: (data) => SliverPreviewPostGrid(
                                posts: data,
                                onTap: (postIdx) => goToPostDetailsPage(
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
      tagListBuilder: (context, post) => E621TagsTile(post: post),
      infoBuilder: (context, post) => SimpleInformationSection(
        post: post,
        showSource: true,
      ),
      placeholderImageUrlBuilder: (post, currentPage) =>
          currentPage == controller.initialPage && post.isTranslated
              ? null
              : post.thumbnailImageUrl,
      parts: kDefaultPostDetailsNoSourceParts,
      artistInfoBuilder: (context, post) => E621ArtistSection(post: post),
    );
  }
}

class E621ArtistSection extends ConsumerWidget {
  const E621ArtistSection({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentary = post.description;

    return ArtistSection(
      commentary: ArtistCommentary.description(commentary),
      artistTags: post.artistTags,
      source: post.source,
    );
  }
}

class E621TagsTile extends ConsumerWidget {
  const E621TagsTile({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TagsTile(
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
    );
  }
}
