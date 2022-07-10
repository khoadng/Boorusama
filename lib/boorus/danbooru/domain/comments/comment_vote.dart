// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';

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
