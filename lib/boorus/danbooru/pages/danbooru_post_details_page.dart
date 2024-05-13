// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/tags/booru_tag_type_store.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/posts/character_post_list.dart';
import 'package:boorusama/core/widgets/widgets.dart';
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
    required this.onPageChanged,
  });

  final int intitialIndex;
  final List<DanbooruPost> posts;
  final void Function(int page) onExit;
  final void Function(int page) onPageChanged;

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
        sourceSectionBuilder: (context, post) => const SizedBox.shrink(),
        onTagTap: (tag) => goToSearchPage(context, tag: tag),
        onPageChangeIndexed: widget.onPageChanged,
        toolbarBuilder: (context, post) =>
            DanbooruPostActionToolbar(post: post),
        swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
        sliverArtistPostsBuilder: (context, post) => post.artistTags.isNotEmpty
            ? post.artistTags
                .map((tag) => ArtistPostList2(
                      tag: tag,
                      builder: (tag) => ref
                          .watch(danbooruPostDetailsArtistProvider(tag))
                          .maybeWhen(
                            data: (data) => SliverPreviewPostGrid(
                              posts: data,
                              onTap: (postIdx) => goToPostDetailsPage(
                                context: context,
                                posts: data,
                                initialIndex: postIdx,
                              ),
                              imageUrl: (item) => item.url360x360,
                            ),
                            orElse: () =>
                                const SliverPreviewPostGridPlaceholder(
                              itemCount: 30,
                            ),
                          ),
                    ))
                .toList()
            : [],
        sliverCharacterPostsBuilder: (context, post) => post.artistTags.isEmpty
            ? CharacterPostList(tags: post.characterTags)
            : ref
                .watch(danbooruPostDetailsArtistProvider(post.artistTags.first))
                .maybeWhen(
                  data: (_) => CharacterPostList(tags: post.characterTags),
                  orElse: () => const SliverSizedBox.shrink(),
                ),
        sliverRelatedPostsBuilder: (context, post) =>
            DanbooruRelatedPostsSection(post: post),
        poolTileBuilder: (context, post) =>
            ref.watch(danbooruPostDetailsPoolsProvider(post.id)).maybeWhen(
                  data: (pools) => PoolTiles(pools: pools),
                  orElse: () => const SizedBox.shrink(),
                ),
        statsTileBuilder: (context, post) => DanbooruPostStatsTile(
          post: post,
          commentCount: ref.watch(danbooruCommentCountProvider(post.id)).value,
        ),
        tagListBuilder: (context, post) => DanbooruTagsTile(post: post),
        infoBuilder: (context, post) => SimpleInformationSection(
          post: post,
          showSource: true,
        ),
        artistInfoBuilder: (context, post) => DanbooruArtistSection(
          post: post,
          commentary:
              ref.watch(danbooruArtistCommentaryProvider(post.id)).value ??
                  ArtistCommentary.empty(),
        ),
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
        topRightButtonsBuilder: (page, expanded, post, controller) {
          return [
            NoteActionButtonWithProvider(
              post: post,
              expanded: expanded,
              noteState: ref.watch(notesControllerProvider(post)),
            ),
            DanbooruMoreActionButton(
              post: post,
              onStartSlideshow: () => controller.startSlideshow(),
            ),
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
    required this.commentCount,
  });

  final DanbooruPost post;
  final int? commentCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimplePostStatsTile(
      score: post.score,
      favCount: post.favCount,
      totalComments: commentCount ?? 0,
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
    required this.commentary,
  });

  final DanbooruPost post;
  final ArtistCommentary commentary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          .toSet();

  final repo = ref.watch(tagRepoProvider(config));

  final tags = await repo.getTagsByName(tagString, 1);

  await ref
      .watch(booruTagTypeStoreProvider)
      .saveTagIfNotExist(config.booruType, tags);

  return createTagGroupItems(tags);
});

final danbooruCharacterExpandStateProvider =
    StateProvider.autoDispose.family<bool, String>((ref, tag) => false);

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
