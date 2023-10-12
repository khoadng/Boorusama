// Package imports:
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/core/feats/forums/forums.dart';

class DanbooruForumTopicsNotifier
    extends PagedNotifier<int, DanbooruForumTopic> {
  DanbooruForumTopicsNotifier({
    required ForumTopicRepository<DanbooruForumTopic> repo,
    required void Function(List<DanbooruForumTopic> data) onLoaded,
  }) : super(
          load: (key, limit) async {
            final topics =
                await repo.getForumTopicsOrEmpty(key).then((value) => value);

            onLoaded(topics);

            return topics;
          },
          nextPageKeyBuilder: NextPageKeyBuilderDefault.mysqlPagination,
        );
}
