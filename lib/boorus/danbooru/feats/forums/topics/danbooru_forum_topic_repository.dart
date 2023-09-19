// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_forums.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

typedef DanbooruForumTopicsOrError
    = TaskEither<BooruError, List<DanbooruForumTopic>>;

abstract interface class DanbooruForumTopicRepository {
  DanbooruForumTopicsOrError getForumTopics(int page);
}

extension DanbooruForumTopicRepositoryX on DanbooruForumTopicRepository {
  Future<List<DanbooruForumTopic>> getForumTopicsOrEmpty(int page) =>
      getForumTopics(page)
          .run()
          .then((value) => value.getOrElse((e) => <DanbooruForumTopic>[]));
}

class DanbooruForumTopicRepositoryApi implements DanbooruForumTopicRepository {
  DanbooruForumTopicRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;

  @override
  DanbooruForumTopicsOrError getForumTopics(int page) =>
      TaskEither.Do(($) async {
        var value = await $(tryFetchRemoteData(
          fetcher: () => client.getForumTopics(
            order: TopicOrder.sticky,
            page: page,
            limit: 50,
          ),
        ));

        var data =
            value.map(danbooruForumTopicDtoToDanbooruForumTopic).toList();

        return data;
      });
}

DanbooruForumTopic danbooruForumTopicDtoToDanbooruForumTopic(
  ForumTopicDto dto,
) =>
    DanbooruForumTopic(
      id: dto.id ?? 0,
      creator: creatorDtoToCreator(dto.creator),
      updater: creatorDtoToCreator(dto.updater),
      title: dto.title ?? '',
      responseCount: dto.responseCount ?? 0,
      isSticky: dto.isSticky ?? false,
      isLocked: dto.isLocked ?? false,
      createdAt: dto.createdAt != null
          ? DateTime.parse(dto.createdAt!)
          : DateTime.now(),
      updatedAt: dto.updatedAt != null
          ? DateTime.parse(dto.updatedAt!)
          : DateTime.now(),
      isDeleted: dto.isDeleted ?? false,
      category: dto.categoryId != null
          ? intToDanbooruTopicCategory(dto.categoryId!)
          : DanbooruTopicCategory.general,
      originalPost: dto.originalPost != null
          ? danbooruForumPostDtoToDanbooruForumPost(dto.originalPost!)
          : DanbooruForumPost.empty(),
    );
