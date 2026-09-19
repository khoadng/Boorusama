// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/comments/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/config/types.dart';
import '../gelbooru_v2_provider.dart';
import 'providers.dart';
import 'types.dart';
import 'vote_notifier.dart';

class GelbooruV2CommentPage extends ConsumerWidget {
  const GelbooruV2CommentPage({
    required this.postId,
    required this.useAppBar,
    super.key,
  });

  final int postId;
  final bool useAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final commentsCapabilities = ref
        .watch(gelbooruV2Provider)
        .getCapabilitiesForSite(config.url)
        ?.comments;
    final hasPagination = switch (commentsCapabilities?.paginationType) {
      'page' || 'offset' || 'cursor' => true,
      _ => false,
    };

    return CommentPageScaffold(
      postId: postId,
      useAppBar: useAppBar,
      singlePage: !hasPagination,
      commentItemBuilder: (context, comment) => switch (comment) {
        final GelbooruV2Comment comment => GelbooruV2CommentItem(
          comment: comment,
          config: config,
        ),
        _ => CommentItem(comment: comment, config: config),
      },
    );
  }
}

class GelbooruV2CommentItem extends ConsumerWidget {
  const GelbooruV2CommentItem({
    required this.comment,
    required this.config,
    super.key,
  });

  final GelbooruV2Comment comment;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postId = comment.postId;
    final validPostId = postId != null && postId > 0 ? postId : null;
    final voteParams = (
      config: config,
      postId: validPostId ?? 0,
      commentId: comment.id,
      initialScore: comment.score,
    );
    final voteState = ref.watch(gelbooruV2CommentVoteProvider(voteParams));
    final showUpvote =
        validPostId != null &&
        ref.watch(gelbooruV2SupportsCommentUpvoteProvider(config));
    final upvoteLabel = context.t.post.action.upvote;
    final showFooter = voteState.score != null || showUpvote;

    return CommentItem(
      comment: comment,
      config: config,
      footerBuilder: showFooter
          ? (_) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showUpvote)
                  Semantics(
                    button: true,
                    label: upvoteLabel,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: upvoteLabel,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      onPressed: voteState.isSubmitting
                          ? null
                          : () async {
                              try {
                                final result = await ref
                                    .read(
                                      gelbooruV2CommentVoteProvider(
                                        voteParams,
                                      ).notifier,
                                    )
                                    .upvote();
                                if (!context.mounted || result == null) return;

                                switch (result) {
                                  case CommentUpvoteResult.voted:
                                    Kurumi.showSuccessToast(
                                      context,
                                      context.t.comment.vote.success,
                                    );
                                  case CommentUpvoteResult.alreadyVoted:
                                    Kurumi.showSuccessToast(
                                      context,
                                      context.t.comment.vote.already_voted,
                                    );
                                  case CommentUpvoteResult.loginRequired:
                                    Kurumi.showErrorToast(
                                      context,
                                      context
                                          .t
                                          .post
                                          .detail
                                          .login_required_notice,
                                    );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  Kurumi.showErrorToast(
                                    context,
                                    context.t.generic.errors.unknown,
                                  );
                                }
                              }
                            },
                      icon: voteState.isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Symbols.arrow_upward_alt),
                    ),
                  ),
                Text(
                  voteState.score?.toString() ?? '—',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            )
          : null,
    );
  }
}
