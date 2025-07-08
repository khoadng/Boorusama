// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/comments/types.dart';
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../users/user/providers.dart';
import '../../../../users/user/user.dart';
import '../../../votes/providers.dart';
import '../data/providers.dart';
import '../types/comment_data.dart';
import '../types/constants.dart';
import '../types/danbooru_comment.dart';

final danbooruCommentsProvider =
    NotifierProvider.family<
      CommentsNotifier,
      Map<int, List<CommentData>?>,
      BooruConfigAuth
    >(
      CommentsNotifier.new,
    );

final danbooruCommentProvider = Provider.autoDispose
    .family<List<CommentData>?, int>((ref, postId) {
      final config = ref.watchConfigAuth;
      return ref.watch(danbooruCommentsProvider(config))[postId];
    });

class CommentsNotifier
    extends FamilyNotifier<Map<int, List<CommentData>?>, BooruConfigAuth> {
  @override
  Map<int, List<CommentData>?> build(BooruConfigAuth arg) {
    return {};
  }

  CommentRepository<DanbooruComment> get _repo =>
      ref.read(danbooruCommentRepoProvider(arg));

  Future<void> load(
    int postId, {
    bool force = false,
  }) async {
    if (state.containsKey(postId) && !force) return;

    final user = await ref.read(danbooruCurrentUserProvider(arg).future);

    final comments = await _repo
        .getComments(postId)
        .then(filterDeleted())
        .then(
          (comments) => comments
              .map(
                (comment) => CommentData(
                  id: comment.id,
                  score: comment.score,
                  authorName: comment.creator?.name ?? 'User',
                  authorLevel: comment.creator?.level ?? UserLevel.member,
                  authorId: comment.creator?.id ?? 0,
                  body: comment.body,
                  createdAt: comment.createdAt,
                  updatedAt: comment.updatedAt,
                  isSelf: comment.creator?.id == user?.id,
                  isEdited: comment.isEdited,
                  uris: RegExp(urlPattern)
                      .allMatches(comment.body)
                      .map(
                        (match) => Uri.tryParse(
                          comment.body.substring(match.start, match.end),
                        ),
                      )
                      .nonNulls
                      .where((e) => e.host.contains(youtubeUrl))
                      .toList(),
                ),
              )
              .toList(),
        )
        .then(_sortDescById);

    state = {
      ...state,
      postId: comments,
    };

    // fetch comment votes, no need to wait
    unawaited(
      ref
          .read(danbooruCommentVotesProvider(arg).notifier)
          .fetch(comments.map((e) => e.id).toList()),
    );
  }

  Future<void> send({
    required int postId,
    required String content,
    CommentData? replyTo,
  }) async {
    await _repo.createComment(
      postId,
      buildCommentContent(content: content, replyTo: replyTo),
    );
    await load(postId, force: true);
  }

  Future<void> delete({
    required int postId,
    required CommentData comment,
  }) async {
    await _repo.deleteComment(comment.id);
    await load(postId, force: true);
  }

  Future<void> update({
    required int postId,
    required CommentId commentId,
    required String content,
  }) async {
    await _repo.updateComment(commentId, content);
    await load(postId, force: true);
  }
}

List<CommentData> _sortDescById(List<CommentData> comments) =>
    comments..sort((b, a) => b.id.compareTo(a.id));
