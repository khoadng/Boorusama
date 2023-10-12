// Project imports:
import 'forum_post_dto.dart';

class ForumTopicDto {
  final int? id;
  final int? creatorId;
  final int? updaterId;
  final String? title;
  final int? responseCount;
  final bool? isSticky;
  final bool? isLocked;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDeleted;
  final int? categoryId;
  final int? minLevel;

  final ForumPostDto? originalPost;

  ForumTopicDto({
    this.id,
    this.creatorId,
    this.updaterId,
    this.title,
    this.responseCount,
    this.isSticky,
    this.isLocked,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.categoryId,
    this.minLevel,
    this.originalPost,
  });

  factory ForumTopicDto.fromJson(Map<String, dynamic> json) {
    return ForumTopicDto(
      id: json['id'],
      creatorId: json['creator_id'],
      updaterId: json['updater_id'],
      title: json['title'],
      responseCount: json['response_count'],
      isSticky: json['is_sticky'],
      isLocked: json['is_locked'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isDeleted: json['is_deleted'],
      categoryId: json['category_id'],
      minLevel: json['min_level'],
      originalPost: json['original_post'] != null
          ? ForumPostDto.fromJson(json['original_post'])
          : null,
    );
  }

  @override
  String toString() => title ?? '';
}
