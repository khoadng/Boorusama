// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';

typedef CommentId = int;
typedef CommentScore = int;
typedef CommentBody = String;
typedef CommentCreatorId = int;
typedef CommentPostId = int;

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.score,
    required this.body,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.creator,
  });

  final CommentId id;
  final CommentScore score;
  final CommentBody body;
  final CommentPostId postId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final User creator;

  @override
  List<Object?> get props => [
        id,
        score,
        body,
        postId,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

bool notDeleted(Comment comment) => !comment.isDeleted;
