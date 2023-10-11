// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/context_menu.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'widgets/details/danbooru_more_action_button.dart';
import 'widgets/details/danbooru_post_action_toolbar.dart';
import 'widgets/details/danbooru_recommend_artist_list.dart';
import 'widgets/details/danbooru_recommend_character_list.dart';
import 'widgets/details/pool_tiles.dart';

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
      tagListBuilder: (context, post) {
        return TagsTile(post: post);
      },
      infoBuilder: (context, post) => SimpleInformationSection(
        post: post,
        showSource: true,
      ),
      artistInfoBuilder: (context, post) => DanbooruArtistSection(post: post),
      swipeImageUrlBuilder: (post) => post.sampleImageUrl,
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
      child: SimplePostStatsTile(
        score: post.score,
        favCount: post.favCount,
        totalComments: comments?.length ?? 0,
        votePercentText: _generatePercentText(post),
      ),
    );
  }

  String _generatePercentText(DanbooruPost post) {
    return post.totalVote > 0
        ? '(${(post.upvotePercent * 100).toInt()}% upvoted)'
        : '';
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

final danbooruTagGroupsProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>, DanbooruPost>((ref, post) async {
  final tagsNotifier = ref.watch(danbooruTagListProvider(ref.watchConfig));

  final tagString = tagsNotifier.containsKey(post.id)
      ? tagsNotifier[post.id]!.allTags
      : post
          .extractTagDetails()
          .where((e) => e.postId == post.id)
          .map((e) => e.name)
          .toList();

  final repo = ref.watch(tagRepoProvider(ref.watchConfig));

  final tags = await repo.getTagsByName(tagString, 1);

  return createTagGroupItems(tags);
});

// ignore: prefer-single-widget-per-file
class TagsTile extends ConsumerWidget {
  const TagsTile({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tagItems = ref.watch(danbooruTagGroupsProvider(post));

    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(
              tags: tagItems.maybeWhen(
                data: (data) => data,
                orElse: () => null,
              ),
              itemBuilder: (context, tag) => ContextMenu<String>(
                items: [
                  PopupMenuItem(
                    value: 'wiki',
                    child: const Text('post.detail.open_wiki').tr(),
                  ),
                  PopupMenuItem(
                    value: 'add_to_favorites',
                    child: const Text('post.detail.add_to_favorites').tr(),
                  ),
                  if (config.hasLoginDetails())
                    PopupMenuItem(
                      value: 'blacklist',
                      child: const Text('post.detail.add_to_blacklist').tr(),
                    ),
                  if (config.hasLoginDetails())
                    PopupMenuItem(
                      value: 'copy_and_move_to_saved_search',
                      child: const Text(
                        'post.detail.copy_and_open_saved_search',
                      ).tr(),
                    ),
                ],
                onSelected: (value) {
                  if (value == 'blacklist') {
                    ref
                        .read(danbooruBlacklistedTagsProvider(config).notifier)
                        .addWithToast(tag: tag.rawName);
                  } else if (value == 'wiki') {
                    launchWikiPage(config.url, tag.rawName);
                  } else if (value == 'copy_and_move_to_saved_search') {
                    Clipboard.setData(
                      ClipboardData(text: tag.rawName),
                    ).then((value) => goToSavedSearchEditPage(context));
                  } else if (value == 'add_to_favorites') {
                    ref.read(favoriteTagsProvider.notifier).add(tag.rawName);
                  }
                },
                child: GestureDetector(
                  onTap: () => goToSearchPage(context, tag: tag.rawName),
                  child: PostTagListChip(
                    tag: tag,
                    maxTagWidth: null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
