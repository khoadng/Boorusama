// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'danbooru_forum_post_dto.dart';

class DanbooruForumPost extends Equatable {
  const DanbooruForumPost({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.body,
    required this.isDeleted,
    required this.topicId,
    required this.creator,
    required this.updater,
  });

  factory DanbooruForumPost.empty() => DanbooruForumPost(
        id: -1,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        body: '',
        isDeleted: false,
        topicId: -1,
        creator: Creator.empty(),
        updater: Creator.empty(),
      );

  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String body;
  final bool isDeleted;
  final int topicId;
  final Creator creator;
  final Creator updater;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        body,
        isDeleted,
        topicId,
        creator,
        updater,
      ];
}

DanbooruForumPost danbooruForumPostDtoToDanbooruForumPost(
    DanbooruForumPostDto dto) {
  return DanbooruForumPost(
    id: dto.id ?? -1,
    createdAt:
        dto.createdAt != null ? DateTime.parse(dto.createdAt!) : DateTime.now(),
    updatedAt:
        dto.updatedAt != null ? DateTime.parse(dto.updatedAt!) : DateTime.now(),
    body: dto.body ?? 'No Body',
    isDeleted: dto.isDeleted ?? false,
    topicId: dto.topicId ?? -1,
    creator: creatorDtoToCreator(dto.creator),
    updater: creatorDtoToCreator(dto.updater),
  );
}
