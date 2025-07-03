// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/comments/types.dart';
import '../../../../../../core/configs/config.dart';
import '../../../../client_provider.dart';
import '../types/danbooru_comment_vote.dart';
import 'converter.dart';

final danbooruCommentVoteRepoProvider = Provider.family<
    CommentVoteRepository<DanbooruCommentVote>, BooruConfigAuth>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return CommentVoteRepositoryBuilder(
    fetch: (commentIds) => client
        .getCommentVotes(
          commentIds: commentIds,
          isDeleted: false,
        )
        .then((value) => value.map(commentVoteDtoToCommentVote).toList()),
    unvote: (commentId) =>
        client.removeCommentVote(commentId: commentId).then((_) => true),
    upvote: (commentId) => client
        .upvoteComment(commentId: commentId)
        .then(commentVoteDtoToCommentVote),
    downvote: (commentId) => client
        .downvoteComment(commentId: commentId)
        .then(commentVoteDtoToCommentVote),
  );
});
