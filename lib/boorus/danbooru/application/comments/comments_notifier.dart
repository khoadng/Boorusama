// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';

const youtubeUrl = 'www.youtube.com';

class CommentsNotifier extends Notifier<Map<int, List<CommentData>?>> {
  @override
  Map<int, List<CommentData>?> build() {
    ref.watch(currentBooruConfigProvider);
    return {};
  }

  CommentRepository get repo => ref.read(danbooruCommentRepoProvider);

  Future<void> load(
    int postId, {
    bool force = false,
  }) async {
    if (state.containsKey(postId) && !force) return;

    final config = ref.watch(currentBooruConfigProvider);
    final accountId = await ref
        .watch(booruUserIdentityProviderProvider)
        .getAccountIdFromConfig(config);

    final comments = await repo
        .getCommentsFromPostId(postId)
        .then(filterDeleted())
        .then((comments) => comments
            .map((comment) => CommentData(
                  id: comment.id,
                  authorName: comment.creator?.name ?? 'User',
                  authorLevel: comment.creator?.level ?? UserLevel.member,
                  authorId: comment.creator?.id ?? 0,
                  body: comment.body,
                  createdAt: comment.createdAt,
                  updatedAt: comment.updatedAt,
                  isSelf: comment.creator?.id == accountId,
                  isEdited: comment.isEdited,
                  uris: RegExp(urlPattern)
                      .allMatches(comment.body)
                      .map((match) => Uri.tryParse(
                          comment.body.substring(match.start, match.end)))
                      .whereNotNull()
                      .where((e) => e.host.contains(youtubeUrl))
                      .toList(),
                ))
            .toList())
        .then(_sortDescById);

    state = {
      ...state,
      postId: comments,
    };

    // fetch comment votes
    ref
        .read(danbooruCommentVotesProvider.notifier)
        .fetch(comments.map((e) => e.id).toList());
  }

  Future<void> send({
    required int postId,
    required String content,
    CommentData? replyTo,
  }) async {
    await repo.postComment(
      postId,
      buildCommentContent(content: content, replyTo: replyTo),
    );
    await load(postId, force: true);
  }

  Future<void> delete({
    required int postId,
    required CommentData comment,
  }) async {
    await repo.deleteComment(comment.id);
    await load(postId, force: true);
  }

  Future<void> update({
    required int postId,
    required CommentId commentId,
    required String content,
  }) async {
    await repo.updateComment(commentId, content);
    await load(postId, force: true);
  }
}

List<CommentData> _sortDescById(List<CommentData> comments) =>
    comments..sort((b, a) => b.id.compareTo(a.id));

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
