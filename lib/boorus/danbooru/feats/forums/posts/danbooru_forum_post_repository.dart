// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

typedef DanbooruForumPostsOrError
    = TaskEither<BooruError, List<DanbooruForumPost>>;

abstract interface class DanbooruForumPostRepository {
  DanbooruForumPostsOrError getForumPosts(int topicId, int lastForumPostId);
}

extension DanbooruForumPostRepositoryX on DanbooruForumPostRepository {
  Future<List<DanbooruForumPost>> getForumPostsOrEmpty(
    int topicId,
    int lastForumPostId,
  ) =>
      getForumPosts(topicId, lastForumPostId)
          .run()
          .then((value) => value.getOrElse((e) => <DanbooruForumPost>[]));
}

const _forumPostParams =
    'id,creator,updater,topic_id,body,created_at,updated_at,is_deleted,votes';

class DanbooruForumPostRepositoryApi implements DanbooruForumPostRepository {
  DanbooruForumPostRepositoryApi({
    required this.api,
    this.onFetched,
  });

  final DanbooruApi api;
  final void Function(List<DanbooruForumPost> posts)? onFetched;

  final limit = 20;

  @override
  DanbooruForumPostsOrError getForumPosts(int topicId, int lastForumPostId) =>
      TaskEither.Do(($) async {
        var response = await $(tryParseResponse(
          fetcher: () => api.getForumPosts(
            topicId: topicId,
            page:
                'a${lastForumPostId - 1}', // offset by one to account for the last post
            only: _forumPostParams,
            limit: limit,
          ),
        ));

        var data = parseResponse(
          value: response,
          converter: (item) => DanbooruForumPostDto.fromJson(item),
        ).map(danbooruForumPostDtoToDanbooruForumPost).toList();

        data.sort((a, b) => a.id.compareTo(b.id));

        onFetched?.call(data);

        return data;
      });
}
