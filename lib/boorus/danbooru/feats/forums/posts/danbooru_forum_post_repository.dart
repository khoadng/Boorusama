// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
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

class DanbooruForumPostRepositoryApi implements DanbooruForumPostRepository {
  DanbooruForumPostRepositoryApi({
    required this.client,
    this.onFetched,
  });

  final DanbooruClient client;
  final void Function(List<DanbooruForumPost> posts)? onFetched;

  final limit = 20;

  @override
  DanbooruForumPostsOrError getForumPosts(int topicId, int lastForumPostId) =>
      TaskEither.Do(($) async {
        var value = await $(tryFetchRemoteData(
          fetcher: () => client.getForumPosts(
            topicId: topicId,
            page:
                'a${lastForumPostId - 1}', // offset by one to account for the last post
            limit: limit,
          ),
        ));

        var data = value.map(danbooruForumPostDtoToDanbooruForumPost).toList();

        data.sort((a, b) => a.id.compareTo(b.id));

        onFetched?.call(data);

        return data;
      });
}
