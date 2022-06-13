// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';

//TODO: remove the author fuckery here, make it pure!
class Comment {
  Comment({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.creatorId,
    required this.body,
    required this.score,
    required this.updatedAt,
    required this.updaterId,
    required this.doNotBumpPost,
    required this.isDeleted,
    required this.isSticky,
    required this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        postId: json['post_id'],
        creatorId: json['creator_id'],
        body: json['body'],
        score: json['score'],
        updatedAt: json['updated_at'],
        updaterId: json['updater_id'],
        doNotBumpPost: json['do_not_bump_post'],
        isDeleted: json['is_deleted'],
        isSticky: json['is_sticky'],
        author: User.placeholder(),
      );

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

  final User author;

  Comment copyWith({
    int? id,
    DateTime? createdAt,
    int? postId,
    int? creatorId,
    String? body,
    int? score,
    String? updatedAt,
    int? updaterId,
    bool? doNotBumpPost,
    bool? isDeleted,
    bool? isSticky,
    User? author,
  }) =>
      Comment(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        postId: postId ?? this.postId,
        creatorId: creatorId ?? this.creatorId,
        body: body ?? this.body,
        score: score ?? this.score,
        updatedAt: updatedAt ?? this.updatedAt,
        updaterId: updaterId ?? this.updaterId,
        doNotBumpPost: doNotBumpPost ?? this.doNotBumpPost,
        isDeleted: isDeleted ?? this.isDeleted,
        isSticky: isSticky ?? this.isSticky,
        author: author ?? this.author,
      );
}
