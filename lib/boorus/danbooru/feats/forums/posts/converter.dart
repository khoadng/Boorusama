// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'danbooru_forum_post.dart';
import 'danbooru_forum_post_dto.dart';
import 'danbooru_forum_post_vote.dart';
import 'danbooru_forum_post_vote_dto.dart';

DanbooruForumPostVote danbooruForumPostVoteDtoToDanbooruForumPostVote(
  DanbooruForumPostVoteDto dto,
) {
  return DanbooruForumPostVote(
    id: dto.id ?? 0,
    forumPostId: dto.forumPostId ?? 0,
    creatorId: dto.creatorId ?? 0,
    score: dto.score ?? 0,
    createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(dto.updatedAt ?? '') ?? DateTime.now(),
  );
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
    votes: dto.votes != null
        ? dto.votes!
            .map(danbooruForumPostVoteDtoToDanbooruForumPostVote)
            .toList()
        : [],
  );
}
