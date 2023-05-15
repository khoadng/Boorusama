// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments/comments_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/core/provider.dart';

class CommentsNotifier
    extends AutoDisposeFamilyNotifier<List<CommentData>?, int> {
  @override
  List<CommentData>? build(int arg) {
    fetch();
    return null;
  }

  CommentRepository get repo => ref.read(danbooruCommentRepoProvider);

  Future<void> fetch() async {
    state = await repo
        .getCommentsFromPostId(arg)
        .then(filterDeleted())
        .then(createCommentDataWith(
          ref.watch(currentBooruConfigRepoProvider),
          ref.watch(booruUserIdentityProviderProvider),
          ref.watch(danbooruCommentVoteRepoProvider),
        ))
        .then(sortDescendedById());
  }

  Future<void> send({
    required String content,
    CommentData? replyTo,
  }) async {
    await repo.postComment(
      arg,
      buildCommentContent(
        content: content,
        replyTo: replyTo,
      ),
    );
    await fetch();
  }

  Future<void> delete({
    required CommentData comment,
  }) async {
    await repo.deleteComment(comment.id);
    await fetch();
  }

  Future<void> update({
    required CommentId commentId,
    required String content,
  }) async {
    await repo.updateComment(commentId, content);
    await fetch();
  }
}

String buildCommentContent({
  required String content,
  CommentData? replyTo,
}) {
  var c = content;
  if (replyTo != null) {
    c = '[quote]\n${replyTo.authorName} said:\n\n${replyTo.body}\n[/quote]\n\n$content';
  }

  return c;
}
