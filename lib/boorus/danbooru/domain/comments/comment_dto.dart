// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';

class CommentDto {
  const CommentDto({
    this.id,
    this.createdAt,
    this.postId,
    this.creatorId,
    this.body,
    this.score,
    this.updatedAt,
    this.updaterId,
    this.doNotBumpPost,
    this.isDeleted,
    this.isSticky,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
        id: json['id'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        postId: json['post_id'],
        creatorId: json['creator_id'],
        body: json['body'],
        score: json['score'],
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        updaterId: json['updater_id'],
        doNotBumpPost: json['do_not_bump_post'],
        isDeleted: json['is_deleted'],
        isSticky: json['is_sticky'],
      );

  final int? id;
  final DateTime? createdAt;
  final int? postId;
  final int? creatorId;
  final String? body;
  final int? score;
  final DateTime? updatedAt;
  final int? updaterId;
  final bool? doNotBumpPost;
  final bool? isDeleted;
  final bool? isSticky;
}

Comment commentDtoToComment(CommentDto d) {
  return Comment(
    id: d.id ?? 0,
    score: d.score ?? 0,
    body: d.body ?? '',
    creatorId: d.creatorId ?? 0,
    postId: d.postId ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
  );
}
