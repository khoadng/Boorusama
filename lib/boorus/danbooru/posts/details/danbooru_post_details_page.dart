// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/router.dart';

class DanbooruPostDetailsPage extends ConsumerStatefulWidget {
  const DanbooruPostDetailsPage({
    super.key,
  });

  @override
  ConsumerState<DanbooruPostDetailsPage> createState() =>
      _DanbooruPostDetailsPageState();
}

class _DanbooruPostDetailsPageState
    extends ConsumerState<DanbooruPostDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<DanbooruPost>(context);
    final posts = data.posts;
    final detailsController = data.controller;

    return DanbooruCreatorPreloader(
      posts: posts,
      child: PostDetailsPageScaffold(
        controller: detailsController,
        posts: posts,
        topRightButtonsBuilder: (controller) {
          final post = InheritedPost.of<DanbooruPost>(context);

          return [
            ValueListenableBuilder(
              valueListenable: controller.expanded,
              builder: (_, expanded, __) => NoteActionButtonWithProvider(
                post: post,
                expanded: expanded,
                noteState: ref.watch(notesControllerProvider(post)),
              ),
            ),
            const SizedBox(width: 8),
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
          ? Row(
              children: [
                Flexible(
                  child: Material(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: InkWell(
                      customBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      onTap: () => goToUserDetailsPage(
                        ref,
                        context,
                        uid: uploader.id,
                        username: uploader.name,
                      ),
                      child: Text(
                        uploader.name.replaceAll('_', ' '),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: uploader.getColor(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      customDetails: approver != null
          ? {
              'Approver': Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => goToUserDetailsPage(
                    ref,
                    context,
                    uid: approver.id,
                    username: approver.name,
                  ),
                  child: Text(
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
      onScoreTap: () => goToPostVotesDetails(context, post),
      onFavCountTap: () => goToPostFavoritesDetails(context, post),
      onTotalCommentsTap: () => goToCommentPage(context, ref, post.id),
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
      : post.tags;

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
    required this.currentPost,
    required this.posts,
  });

  final DanbooruPost currentPost;
  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RelatedPostsSection(
      posts: posts,
      imageUrl: (item) => item.url720x720,
      onViewAll: () => goToSearchPage(
        context,
        tag: currentPost.relationshipQuery,
      ),
      onTap: (index) => goToPostDetailsPage(
        context: context,
        posts: posts,
        initialIndex: index,
      ),
    );
  }
}
