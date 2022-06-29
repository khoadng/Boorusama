// Package imports:
import 'package:equatable/equatable.dart';

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
    required this.creatorId,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
  });

  final CommentId id;
  final CommentScore score;
  final CommentBody body;
  final CommentCreatorId creatorId;
  final CommentPostId postId;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        score,
        body,
        creatorId,
        postId,
        createdAt,
        updatedAt,
      ];
}
