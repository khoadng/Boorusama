// Project imports:
import 'package:boorusama/boorus/danbooru/feat/users/data/user_dto.dart';

class CommentDto {
  const CommentDto({
    this.id,
    this.createdAt,
    this.postId,
    this.body,
    this.score,
    this.updatedAt,
    this.updaterId,
    this.doNotBumpPost,
    this.isDeleted,
    this.isSticky,
    this.creator,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
        id: json['id'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        postId: json['post_id'],
        body: json['body'],
        score: json['score'],
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        updaterId: json['updater_id'],
        doNotBumpPost: json['do_not_bump_post'],
        isDeleted: json['is_deleted'],
        isSticky: json['is_sticky'],
        creator:
            json['creator'] == null ? null : UserDto.fromJson(json['creator']),
      );

  final int? id;
  final DateTime? createdAt;
  final int? postId;
  final String? body;
  final int? score;
  final DateTime? updatedAt;
  final int? updaterId;
  final bool? doNotBumpPost;
  final bool? isDeleted;
  final bool? isSticky;
  final UserDto? creator;
}
