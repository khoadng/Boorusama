// Package imports:
import 'package:equatable/equatable.dart';

enum DanbooruTopicCategory {
  general,
  tags,
  bugsAndFeatures,
}

class DanbooruForumTopic extends Equatable {
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

  final int id;
  final int creatorId;
  final int updaterId;
  final String title;
  final int responseCount;
  final bool isSticky;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DanbooruTopicCategory category;

  @override
  List<Object?> get props => [
        id,
        creatorId,
        updaterId,
        title,
        responseCount,
        isSticky,
        isLocked,
        createdAt,
        updatedAt,
        isDeleted,
        category,
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
