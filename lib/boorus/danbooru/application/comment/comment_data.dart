// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

enum CommentVoteState {
  unvote,
  downvoted,
  upvoted,
}

class CommentData extends Equatable {
  const CommentData({
    required this.id,
    required this.authorName,
    required this.authorLevel,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isSelf,
    required this.recentlyUpdated,
    required this.voteState,
    this.voteId,
  });

  final int id;
  final String authorName;
  final UserLevel authorLevel;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int score;
  final bool isSelf;
  final bool recentlyUpdated;
  final int? voteId;
  final CommentVoteState voteState;

  bool get hasVote => voteState != CommentVoteState.unvote;

  CommentData copyWith({
    int? score,
    CommentVoteState? voteState,
    int? voteId,
  }) =>
      CommentData(
          id: id,
          authorName: authorName,
          authorLevel: authorLevel,
          body: body,
          createdAt: createdAt,
          updatedAt: updatedAt,
          score: score ?? this.score,
          isSelf: isSelf,
          recentlyUpdated: recentlyUpdated,
          voteState: voteState ?? this.voteState,
          voteId: voteId);

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorLevel,
        body,
        createdAt,
        updatedAt,
        score,
        isSelf,
        recentlyUpdated,
        voteState,
        voteId,
      ];
}

CommentData commentDataFrom(
  Comment comment,
  User? user,
  Account account,
  List<CommentVote> votes,
) =>
    CommentData(
        id: comment.id,
        authorName: user?.name.value ?? 'User',
        authorLevel: user?.level ?? UserLevel.member,
        body: comment.body,
        createdAt: comment.createdAt,
        updatedAt: comment.updatedAt,
        score: comment.score,
        isSelf: comment.creator?.id.value == account.id,
        recentlyUpdated: comment.createdAt != comment.updatedAt,
        voteState: _getVoteState(comment, votes),
        voteId: {for (final v in votes) v.commentId: v}[comment.id]?.id);

CommentVoteState _getVoteState(Comment comment, List<CommentVote> votes) {
  final voteMap = {
    for (var i = 0; i < votes.length; i += 1) votes[i].commentId: votes[i]
  };
  final hasVote = voteMap.containsKey(comment.id);

  if (!hasVote) return CommentVoteState.unvote;

  final score = voteMap[comment.id]!.score;

  if (score == 1) {
    return CommentVoteState.upvoted;
  } else if (score == -1) {
    return CommentVoteState.downvoted;
  } else {
    return CommentVoteState.unvote;
  }
}
