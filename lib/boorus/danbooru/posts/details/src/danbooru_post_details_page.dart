// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/boorus/engine/providers.dart';
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
import 'providers.dart';

class DanbooruPostDetailsPage extends StatefulWidget {
  const DanbooruPostDetailsPage({
    super.key,
  });

  @override
  State<DanbooruPostDetailsPage> createState() =>
      _DanbooruPostDetailsPageState();
}

class _DanbooruPostDetailsPageState extends State<DanbooruPostDetailsPage> {
  final _transformController = TransformationController();
  final _isInitPage = ValueNotifier(true);

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<DanbooruPost>(context);
    final posts = data.posts;
    final detailsController = data.controller;

    return DanbooruCreatorPreloader(
      preloadable: PostCreatorsPreloadable.fromPosts(posts),
      child: Consumer(
        builder: (context, ref, child) {
          final auth = ref.watchConfigAuth;
          final viewer = ref.watchConfigViewer;
          final gestures = ref.watchPostGestures;
          final layout = ref.watchLayoutConfigs;
          final booruBuilder = ref.watch(booruBuilderProvider(auth));
          final booruRepo = ref.watch(booruRepoProvider(auth));
          final uiBuilder = booruBuilder?.postDetailsUIBuilder;
          final mediaUrlResolver = ref.watch(
            danbooruMediaUrlResolverProvider(auth),
          );

          return PostDetailsImagePreloader(
            authConfig: auth,
            posts: posts,
            imageUrlBuilder: (post) =>
                mediaUrlResolver.resolveMediaUrl(post, viewer),
            child: PostDetailsNotes(
              posts: posts,
              viewerConfig: viewer,
              authConfig: auth,
              child: PostDetailsPageScaffold(
                isInitPage: _isInitPage,
                transformController: _transformController,
                controller: detailsController,
                layoutConfig: layout,
                posts: posts,
                postGestureHandlerBuilder: booruRepo?.handlePostGesture,
                uiBuilder: uiBuilder,
                gestureConfig: gestures,
                itemBuilder: (context, index) {
                  return PostDetailsItem(
                    index: index,
                    posts: posts,
                    transformController: _transformController,
                    isInitPageListenable: _isInitPage,
                    authConfig: auth,
                    gestureConfig: gestures,
                    imageCacheManager: null,
                    detailsController: detailsController,
                    imageUrlBuilder: (post) =>
                        mediaUrlResolver.resolveMediaUrl(post, viewer),
                  );
                },
                actions: defaultActions(
                  note: NoteActionButtonWithProvider(
                    currentPost: detailsController.currentPost,
                    config: auth,
                  ),
                  fallbackMoreButton: DefaultFallbackBackupMoreButton(
                    layoutConfig: layout,
                    controller: detailsController,
                    authConfig: auth,
                    viewerConfig: viewer,
                  ),
                ),
              ),
            ),
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
