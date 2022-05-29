// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'comment.dart';

class CommentDto {
  CommentDto({
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

  final int id;
  final DateTime createdAt;
  final int postId;
  final int creatorId;
  final String body;
  final int score;
  final String updatedAt;
  final int updaterId;
  final bool doNotBumpPost;
  final bool isDeleted;
  final bool isSticky;

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        postId: json["post_id"],
        creatorId: json["creator_id"],
        body: json["body"],
        score: json["score"],
        updatedAt: json["updated_at"],
        updaterId: json["updater_id"],
        doNotBumpPost: json["do_not_bump_post"],
        isDeleted: json["is_deleted"],
        isSticky: json["is_sticky"],
      );
}

extension CommentDtoX on CommentDto {
  Comment toEntity() {
    return Comment(
      id: id,
      createdAt: createdAt,
      postId: postId,
      creatorId: creatorId,
      body: body,
      score: score,
      updatedAt: updatedAt,
      updaterId: updaterId,
      isDeleted: isDeleted,
      author: User.placeholder(),
    );
  }
}
