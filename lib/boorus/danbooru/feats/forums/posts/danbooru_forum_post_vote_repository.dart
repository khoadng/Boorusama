// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';

abstract interface class DanbooruForumPostVoteRepository {
  Future<List<DanbooruForumPostVote>> getForumPostVotes(int forumPostId);
}

class DanbooruForumPostVoteRepositoryApi
    implements DanbooruForumPostVoteRepository {
  DanbooruForumPostVoteRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;

  @override
  Future<List<DanbooruForumPostVote>> getForumPostVotes(int forumPostId) =>
      client
          .getForumPostVotes(forumPostId: forumPostId)
          .then((value) => value
              .map(danbooruForumPostVoteDtoToDanbooruForumPostVote)
              .toList())
          .catchError((e) => <DanbooruForumPostVote>[]);
}
