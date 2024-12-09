// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/details/details.dart';
import 'package:boorusama/core/posts/details/parts.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/router.dart';
import '../../_shared/danbooru_creator_preloader.dart';
import '../../_shared/post_creator_preloadable.dart';
import '../../post/post.dart';
import 'widgets/danbooru_more_action_button.dart';

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
      preloadable: PostCreatorsPreloadable.fromPosts(posts),
      child: PostDetailsPageScaffold(
        controller: detailsController,
        posts: posts,
        topRightButtonsBuilder: (controller) {
          final post = InheritedPost.of<DanbooruPost>(context);

          return [
            NoteActionButtonWithProvider(
              post: post,
              noteState: ref.watch(notesControllerProvider(post)),
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
