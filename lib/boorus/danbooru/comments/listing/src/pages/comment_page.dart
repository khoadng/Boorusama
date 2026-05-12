// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/comments/widgets.dart';
import '../../../../../../core/configs/config/providers.dart';
import '../../../../configs/providers.dart';
import '../../../comment/providers.dart';
import '../../../comment/types.dart';
import '../../../votes/providers.dart';
import '../routes/route_utils.dart';
import '../widgets/comment_list.dart';
import '../widgets/reply_header.dart';

class CommentPage extends ConsumerWidget {
  const CommentPage({
    required this.postId,
    super.key,
    this.useAppBar = true,
  });

  final int postId;
  final bool useAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
    final comments = ref.watch(danbooruCommentsProvider(config))[postId];
    final commentsNotifier = ref.watch(
      danbooruCommentsProvider(config).notifier,
    );
    final commentVotesNotifier = ref.watch(
      danbooruCommentVotesProvider(config).notifier,
    );

    return CommentThreadPageScaffold<CommentData>(
      useAppBar: useAppBar,
      authenticated: loginDetails.hasLogin(),
      comments: comments,
      onLoad: () => commentsNotifier.load(postId),
      onRefresh: () => commentsNotifier.load(postId, force: true),
      replyHeaderBuilder: (context, comment) => ReplyHeader(comment: comment),
      onOpenEditor: (content, replyTo) {
        var initialContent = content;
        if (replyTo != null) {
          initialContent =
              '[quote]\n${replyTo.authorName} said:\n\n${replyTo.body}\n[/quote]\n\n$content';
        }

        return goToCommentCreatePage(
          ref,
          postId: postId,
          initialContent: initialContent,
        );
      },
      onSend: (content, replyTo) => commentsNotifier.send(
        postId: postId,
        content: content,
        replyTo: replyTo,
      ),
      commentListBuilder: (context, scrollController, onReply) => CommentList(
        scrollController: scrollController,
        comments: comments ?? const [],
        authenticated: loginDetails.hasLogin(),
        onEdit: (comment) {
          goToCommentUpdatePage(
            ref,
            postId: postId,
            commentId: comment.id,
            commentBody: comment.body,
          );
        },
        onReply: onReply,
        onDelete: (comment) => commentsNotifier.delete(
          postId: postId,
          comment: comment,
        ),
        onUpvote: (comment) => commentVotesNotifier.guardUpvote(
          ref,
          comment.id,
        ),
        onDownvote: (comment) => commentVotesNotifier.guardDownvote(
          ref,
          comment.id,
        ),
        onClearVote: (comment, commentVote) => commentVotesNotifier.guardUnvote(
          ref,
          commentVote,
        ),
      ),
    );
  }
}
