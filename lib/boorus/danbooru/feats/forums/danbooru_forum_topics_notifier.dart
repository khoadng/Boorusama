// Package imports:
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/core/feats/forums/forums.dart';

class DanbooruForumTopicsNotifier
    extends PagedNotifier<int, DanbooruForumTopic> {
  DanbooruForumTopicsNotifier({
    required ForumTopicRepository<DanbooruForumTopic> repo,
  }) : super(
          load: (key, limit) =>
              repo.getForumTopicsOrEmpty(key).then((value) => value),
          nextPageKeyBuilder: NextPageKeyBuilderDefault.mysqlPagination,
        );
}
