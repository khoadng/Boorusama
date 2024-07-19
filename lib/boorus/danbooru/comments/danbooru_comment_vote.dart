// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'danbooru_comment.dart';

typedef CommentVoteId = int;

class DanbooruCommentVote extends Equatable implements CommentVote {
  const DanbooruCommentVote({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory DanbooruCommentVote.empty() => DanbooruCommentVote(
        id: -1,
        commentId: -1,
        userId: -1,
        score: 0,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        isDeleted: false,
      );

  final CommentVoteId id;
  @override
  final CommentId commentId;
  final UserId userId;
  @override
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

extension CommentVoteX on DanbooruCommentVote {
  CommentVoteState get voteState => switch (score) {
        -1 => CommentVoteState.downvoted,
        1 => CommentVoteState.upvoted,
        _ => CommentVoteState.unvote,
      };

  DanbooruCommentVote copyWith({
    CommentVoteId? id,
    CommentId? commentId,
    UserId? userId,
    CommentScore? score,
  }) =>
      DanbooruCommentVote(
        id: id ?? this.id,
        commentId: commentId ?? this.commentId,
        userId: userId ?? this.userId,
        score: score ?? this.score,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: isDeleted,
      );
}
