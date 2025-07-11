// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../errors/types.dart';
import '../http/http.dart';

abstract class ForumTopic {
  int get id;
  int? get creatorId;
  int? get updaterId;
  String get title;
  int get responseCount;
  bool get isSticky;
  bool get isLocked;
  DateTime get createdAt;
  DateTime get updatedAt;
}

abstract class ForumTopicRepository<T extends ForumTopic> {
  TaskEither<BooruError, List<T>> getForumTopics(int page);
}

extension ForumTopicRepositoryX<T extends ForumTopic>
    on ForumTopicRepository<T> {
  Future<List<T>> getForumTopicsOrEmpty(int page) =>
      getForumTopics(page).run().then((value) => value.getOrElse((e) => <T>[]));
}

class ForumTopicRepositoryBuilder<T extends ForumTopic>
    implements ForumTopicRepository<T> {
  ForumTopicRepositoryBuilder({
    required this.fetch,
  });

  final Future<List<T>> Function(int page) fetch;

  @override
  TaskEither<BooruError, List<T>> getForumTopics(int page) =>
      TaskEither.Do(($) async {
        final value = await $(
          tryFetchRemoteData(
            fetcher: () => fetch(page),
          ),
        );

        return value;
      });
}
