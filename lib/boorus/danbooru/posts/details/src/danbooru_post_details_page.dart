// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/notes/notes.dart';
import '../../../../../core/posts/details/details.dart';
import '../../../../../core/posts/details/widgets.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../core/router.dart';
import '../../../users/user/routes.dart';
import '../../_shared/danbooru_creator_preloader.dart';
import '../../_shared/post_creator_preloadable.dart';
import '../../post/post.dart';
import 'widgets/danbooru_more_action_button.dart';

class DanbooruPostDetailsPage extends StatelessWidget {
  const DanbooruPostDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<DanbooruPost>(context);
    final posts = data.posts;
    final detailsController = data.controller;
    final pageViewController = data.pageViewController;

    return DanbooruCreatorPreloader(
      preloadable: PostCreatorsPreloadable.fromPosts(posts),
      child: Consumer(
        builder: (context, ref, child) {
          final config = ref.watchConfigAuth;
          final configViewer = ref.watchConfigViewer;
          final post = InheritedPost.of<DanbooruPost>(context);

          return PostDetailsPageScaffold(
            pageViewController: pageViewController,
            controller: detailsController,
            posts: posts,
            viewerConfig: configViewer,
            authConfig: config,
            gestureConfig: ref.watchPostGestures,
            topRightButtons: [
              NoteActionButtonWithProvider(
                post: post,
                config: config,
              ),
              const SizedBox(width: 8),
              DanbooruMoreActionButton(
                post: post,
                config: config,
                configViewer: configViewer,
                onStartSlideshow: () => pageViewController.startSlideshow(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DanbooruPostStatsTile extends ConsumerWidget {
  const DanbooruPostStatsTile({
    required this.post,
    required this.commentCount,
    super.key,
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
      onScoreTap: () => goToPostVotesDetails(ref, post),
      onFavCountTap: () => goToPostFavoritesDetails(ref, post),
      onTotalCommentsTap: () => goToCommentPage(context, ref, post.id),
    );
  }

  String _generatePercentText(DanbooruPost post) {
    return post.totalVote > 0
        ? '(${(post.upvotePercent * 100).toInt()}% upvoted)'
        : '';
  }
}
