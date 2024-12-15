// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/danbooru_topic_category.dart';
import '../types/forum_topic.dart';

DanbooruForumTopic dtoToTopic(ForumTopicDto dto) {
  return DanbooruForumTopic(
    id: dto.id ?? 0,
    creatorId: dto.creatorId ?? 0,
    updaterId: dto.updaterId ?? 0,
    title: dto.title ?? '',
    responseCount: dto.responseCount ?? 0,
    isSticky: dto.isSticky ?? false,
    isLocked: dto.isLocked ?? false,
    createdAt:
        dto.createdAt != null ? DateTime.parse(dto.createdAt!) : DateTime.now(),
    updatedAt:
        dto.updatedAt != null ? DateTime.parse(dto.updatedAt!) : DateTime.now(),
    isDeleted: dto.isDeleted ?? false,
    category: dto.categoryId != null
        ? intToDanbooruTopicCategory(dto.categoryId!)
        : DanbooruTopicCategory.general,
  );
}
