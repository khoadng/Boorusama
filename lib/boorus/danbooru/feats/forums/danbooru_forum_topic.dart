// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/creator.dart';
import 'package:boorusama/core/feats/forums/forums.dart';
import 'danbooru_forum_post.dart';

enum DanbooruTopicCategory {
  general,
  tags,
  bugsAndFeatures,
}

class DanbooruForumTopic extends Equatable implements ForumTopic {
  const DanbooruForumTopic({
    required this.id,
    required this.creator,
    required this.updater,
    required this.title,
    required this.responseCount,
    required this.isSticky,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.category,
    required this.originalPost,
  });

  @override
  final int id;
  final Creator creator;
  final Creator updater;
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

  final DanbooruForumPost originalPost;

  @override
  int? get creatorId => creator.id;

  @override
  int? get updaterId => updater.id;

  @override
  List<Object?> get props => [
        id,
        creator,
        updater,
        title,
        responseCount,
        isSticky,
        isLocked,
        createdAt,
        updatedAt,
        isDeleted,
        category,
        originalPost,
      ];
}

DanbooruTopicCategory intToDanbooruTopicCategory(int value) => switch (value) {
      1 => DanbooruTopicCategory.tags,
      2 => DanbooruTopicCategory.bugsAndFeatures,
      _ => DanbooruTopicCategory.general
    };

int danbooruTopicCategoryToInt(DanbooruTopicCategory value) => switch (value) {
      DanbooruTopicCategory.general => 0,
      DanbooruTopicCategory.tags => 1,
      DanbooruTopicCategory.bugsAndFeatures => 2,
    };
