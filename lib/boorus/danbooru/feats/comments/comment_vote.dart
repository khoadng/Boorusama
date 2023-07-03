// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'comment.dart';

typedef CommentVoteId = int;

class CommentVote extends Equatable {
  const CommentVote({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory CommentVote.empty() => CommentVote(
        id: -1,
        commentId: -1,
        userId: -1,
        score: 0,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        isDeleted: false,
      );

  final CommentVoteId id;
  final CommentId commentId;
  final UserId userId;
  final CommentScore score;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  @override
  List<Object?> get props => [
        id,
        commentId,
        userId,
        score,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

extension CommentVoteX on CommentVote {
  CommentVoteState get voteState => switch (score) {
        -1 => CommentVoteState.downvoted,
        1 => CommentVoteState.upvoted,
        _ => CommentVoteState.unvote,
      };

  CommentVote copyWith({
    CommentVoteId? id,
    CommentId? commentId,
    UserId? userId,
    CommentScore? score,
  }) =>
      CommentVote(
        id: id ?? this.id,
        commentId: commentId ?? this.commentId,
        userId: userId ?? this.userId,
        score: score ?? this.score,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: isDeleted,
      );
}
