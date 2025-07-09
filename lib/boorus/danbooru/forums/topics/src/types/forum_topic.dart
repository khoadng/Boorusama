// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../../core/forums/forum_topic.dart';
import 'danbooru_topic_category.dart';

class DanbooruForumTopic extends Equatable implements ForumTopic {
  const DanbooruForumTopic({
    required this.id,
    required this.creatorId,
    required this.updaterId,
    required this.title,
    required this.responseCount,
    required this.isSticky,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.category,
  });

  @override
  final int id;
  @override
  final String title;
  @override
  final int responseCount;
  @override
  final bool isSticky;
  @override
  final bool isLocked;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final bool isDeleted;
  final DanbooruTopicCategory category;

  @override
  final int creatorId;

  @override
  final int updaterId;

  @override
  List<Object?> get props => [
    id,
    title,
    creatorId,
    updaterId,
    responseCount,
    isSticky,
    isLocked,
    createdAt,
    updatedAt,
    isDeleted,
    category,
  ];
}
