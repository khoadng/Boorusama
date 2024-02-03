// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_creator_preloader.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/tags/booru_tag_type_store.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/danbooru_tags_tile.dart';
import 'widgets/details/danbooru_more_action_button.dart';
import 'widgets/details/danbooru_post_action_toolbar.dart';
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
    return DanbooruCreatorPreloader(
      posts: posts,
      child: PostDetailsPageScaffold(
        posts: posts,
        initialIndex: widget.intitialIndex,
        onExit: widget.onExit,
        showSourceTile: false,
        onTagTap: (tag) => goToSearchPage(context, tag: tag),
        toolbarBuilder: (context, post) =>
            DanbooruPostActionToolbar(post: post),
        swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
        sliverArtistPostsBuilder: (context, post) => post.artistTags.isNotEmpty
            ? ArtistPostList(
                artists: post.artistTags,
                builder: (tag) =>
                    ref.watch(danbooruPostDetailsArtistProvider(tag)).maybeWhen(
                          data: (data) => PreviewPostGrid(
                            posts: data,
                            onTap: (postIdx) => goToPostDetailsPage(
                              context: context,
                              posts: data,
                              initialIndex: postIdx,
                            ),
                            imageUrl: (item) => item.url360x360,
                          ),
                          orElse: () => const PreviewPostGridPlaceholder(
                            imageCount: 30,
                          ),
                        ),
              )
            : const SliverSizedBox.shrink(),
        sliverCharacterPostsBuilder: (context, post) => post.artistTags.isEmpty
            ? DanbooruCharacterPostList(post: post)
            : ref
                .watch(danbooruPostDetailsArtistProvider(post.artistTags.first))
                .maybeWhen(
                  data: (_) => DanbooruCharacterPostList(post: post),
                  orElse: () => const SliverSizedBox.shrink(),
                ),
        sliverRelatedPostsBuilder: (context, post) =>
            DanbooruRelatedPostsSection(post: post),
        poolTileBuilder: (context, post) =>
            ref.watch(danbooruPostDetailsPoolsProvider(post.id)).maybeWhen(
                  data: (pools) => PoolTiles(pools: pools),
                  orElse: () => const SizedBox.shrink(),
                ),
        statsTileBuilder: (context, post) => DanbooruPostStatsTile(post: post),
        onExpanded: (post) => post.loadDetailsFrom(ref),
        tagListBuilder: (context, post) => DanbooruTagsTile(post: post),
        infoBuilder: (context, post) => SimpleInformationSection(
          post: post,
          showSource: true,
        ),
        artistInfoBuilder: (context, post) => DanbooruArtistSection(post: post),
        placeholderImageUrlBuilder: (post, currentPage) =>
            currentPage == widget.intitialIndex && post.isTranslated
                ? null
                : post.thumbnailImageUrl,
        imageOverlayBuilder: (constraints, post) => noteOverlayBuilderDelegate(
          constraints,
          post,
          ref.watch(notesControllerProvider(post)),
        ),
        fileDetailsBuilder: (context, post) => DanbooruFileDetails(post: post),
        topRightButtonsBuilder: (page, expanded, post) {
          final noteState = ref.watch(notesControllerProvider(posts[page]));

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
      ),
    );
  }
}

class DanbooruFileDetails extends ConsumerWidget {
  const DanbooruFileDetails({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagDetails =
        ref.watch(danbooruTagListProvider(ref.watchConfig))[post.id];
    final uploader = ref.watch(danbooruCreatorProvider(post.uploaderId));
    final approver = ref.watch(danbooruCreatorProvider(post.approverId));

    return FileDetailsSection(
      post: post,
      rating: tagDetails != null ? tagDetails.rating : post.rating,
      uploader: uploader != null
          ? Material(
              color: Colors.transparent,
              elevation: 0,
              child: InkWell(
                onTap: () => goToUserDetailsPage(
                  ref,
                  context,
                  uid: uploader.id,
                  username: uploader.name,
                ),
                child: AutoSizeText(
                  uploader.name.replaceAll('_', ' '),
                  maxLines: 1,
                  style: TextStyle(
                    color: uploader.getColor(context),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : null,
      customDetails: approver != null
          ? {
              'Approver': Material(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  onTap: () => goToUserDetailsPage(
                    ref,
                    context,
                    uid: approver.id,
                    username: approver.name,
                  ),
                  child: AutoSizeText(
                    approver.name.replaceAll('_', ' '),
                    maxLines: 1,
                    style: TextStyle(
                      color: uploader.getColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            }
          : null,
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

    return SimplePostStatsTile(
      score: post.score,
      favCount: post.favCount,
      totalComments: comments?.length ?? 0,
      votePercentText: _generatePercentText(post),
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
  final config = ref.watchConfig;
  final tagsNotifier = ref.watch(danbooruTagListProvider(config));

  final tagString = tagsNotifier.containsKey(post.id)
      ? tagsNotifier[post.id]!.allTags
      : post
          .extractTagDetails()
          .where((e) => e.postId == post.id)
          .map((e) => e.name)
          .toList();

  final repo = ref.watch(tagRepoProvider(config));

  final tags = await repo.getTagsByName(tagString, 1);

  await ref
      .watch(booruTagTypeStoreProvider)
      .saveTagIfNotExist(config.booruType, tags);

  return createTagGroupItems(tags);
});

final danbooruCharacterExpandStateProvider =
    StateProvider.autoDispose.family<bool, String>((ref, tag) => false);

class DanbooruCharacterPostList extends ConsumerWidget {
  const DanbooruCharacterPostList({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = post.characterTags;

    if (tags.isEmpty) return const SliverSizedBox.shrink();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Characters',
                  style: context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SliverSizedBox(height: 8),
          SliverGrid.count(
            crossAxisCount: 2,
            childAspectRatio: 4.5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: tags
                .map(
                  (tag) => BooruChip(
                    borderRadius: BorderRadius.circular(4),
                    color: ref.getTagColor(context, 'character'),
                    onPressed: () => goToCharacterPage(context, tag),
                    label: Text(
                      tag.replaceAll('_', ' '),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class DanbooruRelatedPostsSection extends ConsumerWidget {
  const DanbooruRelatedPostsSection({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(danbooruPostDetailsChildrenProvider(post)).maybeWhen(
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
        );
  }
}
