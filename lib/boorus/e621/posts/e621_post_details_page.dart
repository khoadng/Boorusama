// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/e621/artists/artists.dart';
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/boorus/e621/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/tags/tags.dart';

class E621PostDetailsPage extends ConsumerStatefulWidget {
  const E621PostDetailsPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onExit,
    required this.onPageChanged,
  });

  final int intitialIndex;
  final List<E621Post> posts;
  final void Function(int page) onExit;
  final void Function(int page) onPageChanged;

  @override
  ConsumerState<E621PostDetailsPage> createState() =>
      _E621PostDetailsPageState();
}

class _E621PostDetailsPageState extends ConsumerState<E621PostDetailsPage> {
  List<E621Post> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.intitialIndex,
      onExit: widget.onExit,
      onPageChangeIndexed: widget.onPageChanged,
      toolbarBuilder: (context, post) => DefaultPostActionToolbar(post: post),
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      sliverArtistPostsBuilder: (context, post) => post.artistTags.isNotEmpty
          ? post.artistTags
              .map((tag) => ArtistPostList2(
                    tag: tag,
                    builder: (tag) => ref
                        .watch(e621ArtistPostsProvider(tag))
                        .maybeWhen(
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
                          orElse: () => const SliverPreviewPostGridPlaceholder(
                            
                          ),
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
          currentPage == widget.intitialIndex && post.isTranslated
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
