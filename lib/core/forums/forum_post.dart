// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../errors/types.dart';
import '../http/http.dart';

abstract class ForumPost {
  int get id;
  int get creatorId;
  String get body;
  DateTime get createdAt;
  DateTime get updatedAt;
}

abstract class ForumPostRepository<T extends ForumPost> {
  TaskEither<BooruError, List<T>> getForumPosts(
    int topicId, {
    required int page,
    int? limit,
  });
}

extension ForumPostRepositoryX<T extends ForumPost> on ForumPostRepository<T> {
  Future<List<T>> getForumPostsOrEmpty(
    int topicId, {
    required int page,
    int? limit,
  }) => getForumPosts(
    topicId,
    page: page,
    limit: limit,
  ).run().then((value) => value.getOrElse((e) => <T>[]));
}

class ForumPostRepositoryBuilder<T extends ForumPost>
    implements ForumPostRepository<T> {
  ForumPostRepositoryBuilder({
    required this.fetch,
  });

  final Future<List<T>> Function(int topicId, {required int page, int? limit})
  fetch;

  @override
  TaskEither<BooruError, List<T>> getForumPosts(
    int topicId, {
    required int page,
    int? limit,
  }) => TaskEither.Do(($) async {
    final value = await $(
      tryFetchRemoteData(
        fetcher: () => fetch(topicId, page: page, limit: limit),
      ),
    );

    return value;
  });
}
