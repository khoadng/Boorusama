// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';

class CommentVoteDto {
  CommentVoteDto({
    this.id,
    this.commentId,
    this.userId,
    this.score,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  factory CommentVoteDto.fromJson(Map<String, dynamic> json) => CommentVoteDto(
        id: json['id'],
        commentId: json['comment_id'],
        userId: json['user_id'],
        score: json['score'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        isDeleted: json['is_deleted'],
      );

  final int? id;
  final int? commentId;
  final int? userId;
  final int? score;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDeleted;
}

CommentVote commentVoteDtoToCommentVote(CommentVoteDto d) {
  return CommentVote(
    id: d.id ?? 0,
    commentId: d.commentId ?? 0,
    userId: UserId(d.userId ?? 0),
    score: d.score ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    isDeleted: d.isDeleted ?? false,
  );
}
