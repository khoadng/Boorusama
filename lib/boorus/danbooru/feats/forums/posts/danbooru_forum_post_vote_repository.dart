// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/foundation/http/http.dart';

abstract interface class DanbooruForumPostVoteRepository {
  Future<List<DanbooruForumPostVote>> getForumPostVotes(int forumPostId);
}

const _params = 'id,forum_post_id,score,created_at,updated_at,creator';

class DanbooruForumPostVoteRepositoryApi
    implements DanbooruForumPostVoteRepository {
  DanbooruForumPostVoteRepositoryApi({
    required this.api,
  });

  final DanbooruApi api;

  @override
  Future<List<DanbooruForumPostVote>> getForumPostVotes(int forumPostId) => api
      .getForumPostVotes(forumPostId: forumPostId, only: _params)
      .then((value) => parseResponse(
            value: value,
            converter: (item) => DanbooruForumPostVoteDto.fromJson(item),
          ))
      .then((value) =>
          value.map(danbooruForumPostVoteDtoToDanbooruForumPostVote).toList())
      .catchError((e) => <DanbooruForumPostVote>[]);
}
