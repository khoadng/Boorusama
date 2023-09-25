// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/tags/tags_providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/artist_section.dart';
import 'package:boorusama/boorus/core/widgets/note_action_button.dart';
import 'package:boorusama/boorus/core/widgets/posts/information_section.dart';
import 'package:boorusama/boorus/core/widgets/related_posts_section.dart';
import 'package:boorusama/boorus/danbooru/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'danbooru_more_action_button.dart';
import 'danbooru_post_action_toolbar.dart';
import 'danbooru_recommend_artist_list.dart';
import 'danbooru_recommend_character_list.dart';
import 'pool_tiles.dart';
import 'post_stats_tile.dart';
import 'post_tag_list.dart';

class DanbooruPostDetailsPage extends ConsumerStatefulWidget {
  const DanbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onExit,
  });

  final int intitialIndex;
  final List<DanbooruPost> posts;
  final void Function(int page) onExit;

  @override
  ConsumerState<DanbooruPostDetailsPage> createState() =>
      _DanbooruPostDetailsPageState();
}

class _DanbooruPostDetailsPageState
    extends ConsumerState<DanbooruPostDetailsPage> {
  List<DanbooruPost> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.intitialIndex,
      onExit: widget.onExit,
      showSourceTile: false,
      onTagTap: (tag) => goToSearchPage(context, tag: tag),
      toolbarBuilder: (context, post) => DanbooruPostActionToolbar(post: post),
      sliverArtistPostsBuilder: (context, post) => ref
          .watch(danbooruPostDetailsArtistProvider(post))
          .maybeWhen(
            data: (artists) => DanbooruRecommendArtistList(artists: artists),
            orElse: () => const SliverToBoxAdapter(),
          ),
      sliverCharacterPostsBuilder: (context, post) =>
          ref.watch(danbooruPostDetailsCharacterProvider(post)).maybeWhen(
                data: (characters) =>
                    DanbooruRecommendCharacterList(characters: characters),
                orElse: () => const SliverToBoxAdapter(),
              ),
      sliverRelatedPostsBuilder: (context, post) =>
          ref.watch(danbooruPostDetailsChildrenProvider(post)).maybeWhen(
                data: (posts) => RelatedPostsSection(
                  posts: posts,
                  imageUrl: (item) => item.url720x720,
                  onTap: (index) => goToPostDetailsPage(
                    context: context,
                    posts: posts,
                    initialIndex: index,
                  ),
                ),
                orElse: () => const SliverSizedBox.shrink(),
              ),
      poolTileBuilder: (context, post) =>
          ref.watch(danbooruPostDetailsPoolsProvider(post.id)).maybeWhen(
                data: (pools) => PoolTiles(pools: pools),
                orElse: () => const SizedBox.shrink(),
              ),
      statsTileBuilder: (context, post) => DanbooruPostStatsTile(post: post),
      onExpanded: (post) => post.loadDetailsFrom(ref),
      tagListBuilder: (context, post) => TagsTile(
          tags: post
              .extractTagDetails()
              .where((e) => e.postId == post.id)
              .map((e) => e.name)
              .toList()),
      infoBuilder: (context, post) => SimpleInformationSection(
        post: post,
        showSource: true,
      ),
      artistInfoBuilder: (context, post) => DanbooruArtistSection(post: post),
      swipeImageUrlBuilder: (post) =>
          post.thumbnailFromSettings(ref.watch(settingsProvider)),
      placeholderImageUrlBuilder: (post, currentPage) =>
          currentPage == widget.intitialIndex && post.isTranslated
              ? null
              : post.thumbnailImageUrl,
      imageOverlayBuilder: (constraints, post) => noteOverlayBuilderDelegate(
        constraints,
        post,
        ref.watch(notesControllerProvider(post)),
      ),
      topRightButtonsBuilder: (page, expanded) {
        final noteState = ref.watch(notesControllerProvider(posts[page]));
        final post = posts[page];

        return [
          NoteActionButton(
            post: post,
            showDownload: !expanded && noteState.notes.isEmpty,
            enableNotes: noteState.enableNotes,
            onDownload: () =>
                ref.read(notesControllerProvider(post).notifier).load(),
            onToggleNotes: () => ref
                .read(notesControllerProvider(post).notifier)
                .toggleNoteVisibility(),
          ),
          DanbooruMoreActionButton(post: post),
        ];
      },
    );
  }
}

class DanbooruPostStatsTile extends ConsumerWidget {
  const DanbooruPostStatsTile({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(danbooruCommentProvider(post.id));

    return RepaintBoundary(
      child: PostStatsTile(
        post: post,
        totalComments: comments?.length ?? 0,
      ),
    );
  }
}

class DanbooruArtistSection extends ConsumerWidget {
  const DanbooruArtistSection({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentary = ref.watch(danbooruArtistCommentaryProvider(post.id));

    return ArtistSection(
      commentary: commentary,
      artistTags: post.artistTags,
      source: post.source,
    );
  }
}

// ignore: prefer-single-widget-per-file
class TagsTile extends ConsumerWidget {
  const TagsTile({
    super.key,
    required this.tags,
  });

  final List<String> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) => value
            ? ref.read(tagsProvider(booruConfig).notifier).load(tags)
            : null,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
