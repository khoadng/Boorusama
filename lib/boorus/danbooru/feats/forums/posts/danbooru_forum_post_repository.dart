// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

typedef DanbooruForumPostsOrError
    = TaskEither<BooruError, List<DanbooruForumPost>>;

abstract interface class DanbooruForumPostRepository {
  DanbooruForumPostsOrError getForumPosts(int topicId, int page);
}

extension DanbooruForumPostRepositoryX on DanbooruForumPostRepository {
  Future<List<DanbooruForumPost>> getForumPostsOrEmpty(
    int topicId,
    int page,
  ) =>
      getForumPosts(topicId, page)
          .run()
          .then((value) => value.getOrElse((e) => <DanbooruForumPost>[]));
}

const _forumPostParams =
    'id,creator,updater,topic_id,body,created_at,updated_at,is_deleted';

class DanbooruForumPostRepositoryApi implements DanbooruForumPostRepository {
  DanbooruForumPostRepositoryApi({
    required this.api,
  });

  final DanbooruApi api;

  @override
  DanbooruForumPostsOrError getForumPosts(int topicId, int page) =>
      TaskEither.Do(($) async {
        var response = await $(tryParseResponse(
          fetcher: () => api.getForumPosts(
            topicId: topicId,
            page: page,
            only: _forumPostParams,
          ),
        ));

        var data = parseResponse(
          value: response,
          converter: (item) => DanbooruForumPostDto.fromJson(item),
        ).map(danbooruForumPostDtoToDanbooruForumPost).toList();

        return data;
      });
}
