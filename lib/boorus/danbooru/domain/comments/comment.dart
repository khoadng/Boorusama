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

  factory Comment.emty() => Comment(
        id: -1,
        score: 0,
        body: '',
        postId: -1,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        isDeleted: false,
        creator: null,
      );

  Comment copyWith({
    CommentId? id,
    bool? isDeleted,
    String? body,
  }) =>
      Comment(
        id: id ?? this.id,
        score: score,
        body: body ?? this.body,
        postId: postId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        creator: creator,
      );

  final CommentId id;
  final CommentScore score;
  final CommentBody body;
  final CommentPostId postId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final User? creator;

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
