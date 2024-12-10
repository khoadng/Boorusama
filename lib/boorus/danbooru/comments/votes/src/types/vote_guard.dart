// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../_shared/guard_login.dart';
import '../comment_votes_notifier.dart';
import 'danbooru_comment_vote.dart';

extension CommentVotesNotifierX on CommentVotesNotifier {
  Future<void> guardUpvote(WidgetRef ref, int commentId) async => guardLogin(
        ref,
        () async => upvote(commentId),
      );

  Future<void> guardDownvote(WidgetRef ref, int commentId) async => guardLogin(
        ref,
        () async => downvote(commentId),
      );

  Future<void> guardUnvote(
          WidgetRef ref, DanbooruCommentVote? commentVote) async =>
      guardLogin(
        ref,
        () async => unvote(commentVote),
      );
}
