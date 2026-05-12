// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/comments/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../configs/providers.dart';
import 'providers.dart';
import 'src/routes/route_utils.dart';
import 'types.dart';

class SzurubooruCommentPage extends ConsumerWidget {
  const SzurubooruCommentPage({
    required this.postId,
    required this.useAppBar,
    super.key,
  });

  final int postId;
  final bool useAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(szurubooruLoginDetailsProvider(config));
    final commentsState = ref.watch(
      szurubooruCommentsProvider(config),
    )[postId];
    final commentsNotifier = ref.watch(
      szurubooruCommentsProvider(config).notifier,
    );
    final comments = commentsState?.valueOrNull;

    return CommentThreadPageScaffold<SzurubooruComment>(
      useAppBar: useAppBar,
      authenticated: loginDetails.hasLogin(),
      comments: comments,
      loading: commentsState == null || commentsState.isLoading,
      error: commentsState?.error,
      scrollAfterSend: CommentThreadScrollTarget.end,
      onLoad: () => commentsNotifier.load(postId),
      onRefresh: () => commentsNotifier.load(postId, force: true),
      onOpenEditor: (text, replyTo) => goToSzurubooruCommentCreatePage(
        ref,
        postId: postId,
        initialContent: text,
      ),
      onSend: (text, replyTo) => commentsNotifier.send(
        postId: postId,
        content: text,
      ),
      commentListBuilder: (context, scrollController, onReply) =>
          _SzurubooruCommentList(
            scrollController: scrollController,
            comments: comments ?? const [],
            authenticated: loginDetails.hasLogin(),
            currentUsername: config.login,
          ),
    );
  }
}

class _SzurubooruCommentList extends ConsumerWidget {
  const _SzurubooruCommentList({
    required this.scrollController,
    required this.comments,
    required this.authenticated,
    required this.currentUsername,
  });

  final ScrollController scrollController;
  final List<SzurubooruComment> comments;
  final bool authenticated;
  final String? currentUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(szurubooruCommentsProvider(config).notifier);

    return CommentListView<SzurubooruComment>(
      scrollController: scrollController,
      comments: comments,
      authenticated: authenticated,
      isSelf: (comment) =>
          currentUsername != null && comment.creatorName == currentUsername,
      onEdit: (comment) => goToSzurubooruCommentUpdatePage(
        ref,
        postId: comment.postId,
        commentId: comment.id,
        commentBody: comment.body,
      ),
      onDelete: notifier.delete,
      itemBuilder: (context, comment, onReply, moreBuilder) =>
          CommentThreadItem(
            authorName: comment.creatorName ?? 'Anon',
            createdAt: comment.createdAt,
            body: SelectableText(comment.body),
            isEdited: comment.isEdited,
            updatedAt: comment.updatedAt,
            score: comment.score,
            voteState: comment.voteState,
            onVote: authenticated
                ? (event) => switch (event) {
                    VoteEvent.upvoted => notifier.upvote(comment),
                    VoteEvent.downvote => notifier.downvote(comment),
                    VoteEvent.voteRemoved => notifier.unvote(comment),
                  }
                : null,
            moreBuilder: moreBuilder,
          ),
    );
  }
}
