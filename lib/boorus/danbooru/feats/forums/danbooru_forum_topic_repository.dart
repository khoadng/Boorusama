import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

import 'danbooru_forum_topic.dart';
import 'danbooru_forum_topic_dto.dart';

typedef DanbooruForumTopicsOrError
    = TaskEither<BooruError, IList<DanbooruForumTopic>>;

abstract interface class DanbooruForumTopicRepository {
  DanbooruForumTopicsOrError getForumTopics(int page);
}

extension DanbooruForumTopicRepositoryX on DanbooruForumTopicRepository {
  Future<IList<DanbooruForumTopic>> getForumTopicsOrEmpty(int page) =>
      getForumTopics(page)
          .run()
          .then((value) => value.getOrElse((e) => <DanbooruForumTopic>[].lock));
}

class DanbooruForumTopicRepositoryApi implements DanbooruForumTopicRepository {
  DanbooruForumTopicRepositoryApi({
    required this.api,
    required this.booruConfig,
  });

  final DanbooruApi api;
  final BooruConfig booruConfig;

  @override
  DanbooruForumTopicsOrError getForumTopics(int page) =>
      TaskEither.Do(($) async {
        var response = await $(tryParseResponse(
          fetcher: () => api.getForumTopics(
            booruConfig.login,
            booruConfig.apiKey,
            order: 'sticky',
            page: page,
            limit: 50,
          ),
        ));

        var data = parseResponse(
          value: response,
          converter: (item) => DanbooruForumTopicDto.fromJson(item),
        ).map(danbooruForumTopicDtoToDanbooruForumTopic).toIList();

        return data;
      });
}

DanbooruForumTopic danbooruForumTopicDtoToDanbooruForumTopic(
  DanbooruForumTopicDto dto,
) =>
    DanbooruForumTopic(
      id: dto.id ?? 0,
      creatorId: dto.creatorId ?? 0,
      updaterId: dto.updaterId ?? 0,
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
    );
