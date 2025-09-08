// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/auth/auth.dart';
import '../comment_votes_notifier.dart';
import 'danbooru_comment_vote.dart';

extension CommentVotesNotifierX on CommentVotesNotifier {
  Future<void> guardUpvote(WidgetRef ref, int commentId) async => guardLogin(
    ref,
    () => upvote(commentId),
  );

  Future<void> guardDownvote(WidgetRef ref, int commentId) async => guardLogin(
    ref,
    () => downvote(commentId),
  );

  Future<void> guardUnvote(
    WidgetRef ref,
    DanbooruCommentVote? commentVote,
  ) async => guardLogin(
    ref,
    () => unvote(commentVote),
  );
}
